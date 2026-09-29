{
  # Kodai (github.com/zepzeper/kodai) on a server, natively: what its
  # compose.yaml runs, as NixOS services.
  #
  #   nginx        the site, on port 80, reachable over the tailnet only
  #   PHP-FPM 8.5  with the extensions Kodai needs (redis added to the
  #                defaults) and php.ini next to this file
  #   MariaDB 11.8 database kodai; the kodai system user logs in over the
  #                socket, so there is no database password
  #   Redis        on localhost
  #   Mailpit      catches all mail; its inbox on port 8025, over the tailnet
  #   workers      one per queue (default, logs, webhooks, mail) and the
  #                scheduler, as systemd services, stopped gracefully (SIGTERM,
  #                a minute to finish the job in hand)
  #
  # The code is not built by Nix: it is a checkout in /srv/kodai, deployed
  # with `kodai-deploy <ref>` (the deploy script next to this file). Its .env
  # is the secret kodai-env (env.example next to this file shows what goes
  # in). Before the first deploy the workers simply do not start.
  flake.modules.nixos.services-kodai =
    {
      config,
      lib,
      pkgs,
      secretFile,
      ...
    }:
    let
      cfg = config.zep.kodai;
      dir = "/srv/kodai";
      envFile = secretFile "kodai-env";

      php = pkgs.php85.buildEnv {
        extensions = { enabled, all }: enabled ++ [ all.redis ];
        extraConfig = builtins.readFile ./php.ini;
      };

      deploy = pkgs.writeShellApplication {
        name = "kodai-deploy";
        runtimeInputs = [
          php
          php.packages.composer
          pkgs.git
          pkgs.openssh
          pkgs.coreutils
        ];
        text = builtins.readFile ./deploy;
      };

      # What every Kodai process needs to run.
      service = description: command: {
        inherit description;
        wantedBy = [ "multi-user.target" ];
        after = [
          "mysql.service"
          "redis.service"
        ];
        wants = [
          "mysql.service"
          "redis.service"
        ];
        # Nothing to run before the first deploy.
        unitConfig.ConditionPathExists = "${dir}/vendor/autoload.php";
        serviceConfig = {
          User = "kodai";
          Group = "kodai";
          WorkingDirectory = dir;
          ExecStart = "${php}/bin/php bin/kodai ${command}";
          KillSignal = "SIGTERM";
          TimeoutStopSec = 60;
          Restart = "always";
          RestartSec = 5;
        };
      };

      queues = [
        "default"
        "logs"
        "webhooks"
        "mail"
      ];
    in
    {
      key = "zep#services-kodai";
      options.zep.kodai.enable = lib.mkEnableOption "Kodai, with its database, cache, mail catcher and workers";

      config = lib.mkIf cfg.enable {
        users = {
          users.kodai = {
            isSystemUser = true;
            group = "kodai";
            # The deploy key and composer's cache live here, not in the
            # checkout.
            home = "/var/lib/kodai";
            createHome = true;
          };
          groups.kodai = { };
          # nginx serves public/ and reaches the PHP-FPM socket.
          users.${config.services.nginx.user}.extraGroups = [ "kodai" ];
        };

        systemd.tmpfiles.rules = [ "d ${dir} 0750 kodai kodai -" ];

        age.secrets.kodai-env = lib.mkIf (envFile != null) {
          file = envFile;
          owner = "kodai";
        };

        services = {
          phpfpm.pools.kodai = {
            user = "kodai";
            group = "kodai";
            phpPackage = php;
            settings = {
              "listen.owner" = config.services.nginx.user;
              "listen.group" = config.services.nginx.group;
              pm = "dynamic";
              "pm.max_children" = 8;
              "pm.start_servers" = 2;
              "pm.min_spare_servers" = 1;
              "pm.max_spare_servers" = 4;
              "catch_workers_output" = true;
            };
          };

          # As Kodai's docker/nginx/default.conf.
          nginx = {
            enable = true;
            # Uploads up to php.ini's 50M (nginx's own default is 10M).
            clientMaxBodySize = "50m";
            recommendedOptimisation = true;
            recommendedGzipSettings = true;
            recommendedProxySettings = true;
            virtualHosts.kodai = {
              default = true;
              root = "${dir}/public";
              extraConfig = "index index.php;";
              locations = {
                "/".tryFiles = "$uri $uri/ /index.php?$query_string";
                "~ \\.php$".extraConfig = ''
                  try_files $uri =404;
                  include ${config.services.nginx.package}/conf/fastcgi_params;
                  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                  fastcgi_param DOCUMENT_ROOT $document_root;
                  fastcgi_pass unix:${config.services.phpfpm.pools.kodai.socket};
                '';
                # OAuth metadata, JWKS and ACME challenges live here.
                "^~ /.well-known/".tryFiles = "$uri $uri/ /index.php?$query_string";
                # Everything else starting with a dot (.env, .git) stays hidden.
                "~ /\\.(?!well-known)".extraConfig = "deny all;";
              };
            };
          };

          mysql = {
            enable = true;
            package = pkgs.mariadb_118;
            # Everything uses the socket; nothing listens on the network.
            settings.mysqld.bind-address = "127.0.0.1";
            ensureDatabases = [ "kodai" ];
            ensureUsers = [
              {
                name = "kodai";
                ensurePermissions."kodai.*" = "ALL PRIVILEGES";
              }
            ];
          };

          redis.servers."" = {
            enable = true;
            bind = "127.0.0.1";
          };

          mailpit.instances.kodai = {
            database = "mailpit.db";
            listen = "0.0.0.0:8025";
            smtp = "127.0.0.1:1025";
          };
        };

        # The site and the mail inbox answer over the tailnet only.
        networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
          80
          8025
        ];

        systemd.services =
          lib.mapAttrs
            (
              _: unit:
              unit
              // {
                # A changed .env reaches the long-running processes too.
                restartTriggers = lib.optional (envFile != null) envFile;
              }
            )
            (
              {
                kodai-scheduler = service "Kodai scheduler" "schedule:work";
              }
              // lib.listToAttrs (
                map (
                  queue:
                  lib.nameValuePair "kodai-worker-${queue}" (
                    service "Kodai queue worker (${queue})" (
                      "queue:work" + lib.optionalString (queue != "default") " --queue=${queue}"
                    )
                  )
                ) queues
              )
            );

        # The deploy key clones from GitHub without asking about its host key.
        programs.ssh.knownHosts."github.com".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

        environment.systemPackages = [
          deploy
          php
          php.packages.composer
        ];

        assertions = [
          {
            assertion = config.zep.tailscale.enable;
            message = "zep.kodai answers over the tailnet only: turn on zep.tailscale too.";
          }
        ];
      };
    };
}
