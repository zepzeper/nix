{
  # The platform for Kodai (github.com/zepzeper/kodai): everything its
  # compose.yaml runs, as NixOS services, but not the application itself.
  # Kodai's CI deploys the code and its .env; this only prepares where they
  # go and runs what is there.
  #
  #   nginx        the site, over the tailnet only: port 80, or HTTPS on
  #                options.domain once the cloudflare-dns secret exists
  #   PHP-FPM 8.5  the extensions Kodai needs (redis and mailparse added to
  #                the defaults),
  #                php.ini next to this file
  #   MariaDB 11.8 database kodai; users log in over the socket as their
  #                system user (kodai runs the app, deploy migrates), so there
  #                is no database password
  #   Redis        on localhost
  #   Mailpit      catches all mail; its inbox on port 8025, over the tailnet
  #   workers      one per queue (default, logs, webhooks, mail) and the
  #                scheduler: kodai.target, stopped gracefully (SIGTERM, a
  #                minute to finish the job in hand), sandboxed
  #
  # What the deploy finds (all under /srv/kodai):
  #
  #   releases/<id>/  one directory per release, uploaded by CI, with its
  #                   own .env (written by CI, never by this repository)
  #   current         symlink to the live release (nginx, PHP and the workers
  #                   run from here)
  #   shared/var/<id>/ each release's var/ (its cache), the only place the
  #                   app can write; the release's var/ links here, so a
  #                   release never sees another release's cache
  #
  # CI logs in as `deploy` with the key(s) in deploy_keys (restricted: no
  # terminal, no forwarding), owns releases/ and shared/, runs the
  # migrations, switches current, and may do exactly two things as root:
  # `systemctl reload phpfpm-kodai.service` and `systemctl restart
  # kodai.target` (allowed by polkit, no sudo). The app runs as `kodai`,
  # which can read the code and write only shared/var. nginx is in no Kodai
  # group: it passes through the directories and reads public/ only (made
  # world-readable by the deploy), so it can neither read .env nor write the
  # cache. The database user kodai reads and writes rows; only deploy
  # changes the schema.
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
      inherit (cfg.options) domain;

      # HTTPS for options.domain: a Let's Encrypt certificate through a
      # Cloudflare DNS challenge (the name only points at the tailnet, so the
      # usual HTTP challenge cannot reach it). Until the secret exists the
      # site answers over plain HTTP.
      dnsToken = secretFile "cloudflare-dns";
      https = domain != null && dnsToken != null;
      dir = "/srv/kodai";

      php = pkgs.php85.buildEnv {
        # On top of the defaults: redis (sessions, cache, queues) and
        # mailparse (reading incoming mail; composer refuses to install
        # without it).
        extensions =
          { enabled, all }:
          enabled
          ++ [
            all.redis
            all.mailparse
          ];
        extraConfig = builtins.readFile ./php.ini;
      };

      startsWithKeyType =
        key:
        lib.any (type: lib.hasPrefix type key) [
          "ssh-"
          "ecdsa-"
          "sk-"
        ];

      deployKeys = lib.filter (line: line != "" && !lib.hasPrefix "#" line) (
        lib.splitString "\n" (builtins.readFile ./deploy_keys)
      );

      # The sandbox every Kodai process runs in: read-only system, its own
      # /tmp, no devices, no kernel knobs, network only over IP and sockets,
      # and write access to shared/var alone.
      sandbox = {
        ProtectSystem = "strict";
        ReadWritePaths = [ "${dir}/shared/var" ];
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        SystemCallArchitectures = "native";
        CapabilityBoundingSet = "";
        # Group-writable: deploy (in the kodai group) removes old caches.
        UMask = "0007";
      };

      worker = description: command: {
        inherit description;
        wantedBy = [ "kodai.target" ];
        partOf = [ "kodai.target" ];
        after = [
          "mysql.service"
          "redis.service"
          "mailpit-kodai.service"
        ];
        wants = [
          "mysql.service"
          "redis.service"
        ];
        # Nothing to run before the first deploy.
        unitConfig.ConditionPathExists = "${dir}/current/vendor/autoload.php";
        serviceConfig = sandbox // {
          User = "kodai";
          Group = "kodai";
          WorkingDirectory = "${dir}/current";
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
      options.zep.kodai = {
        enable = lib.mkEnableOption "the platform Kodai is deployed onto";
        options.domain = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "staging.krugten.org";
          description = ''
            The site's name. Its DNS record points at the machine's tailnet
            address, so it still answers over the tailnet only. With the
            cloudflare-dns secret (a Cloudflare API token that may edit the
            zone's DNS) it gets a certificate and answers over HTTPS.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = config.zep.tailscale.enable;
            message = "zep.kodai answers over the tailnet only: turn on zep.tailscale too.";
          }
        ];

        users = {
          groups = {
            kodai = { };
            deploy = { };
          };
          users = {
            # Runs the application.
            kodai = {
              isSystemUser = true;
              group = "kodai";
            };
            # CI's login: uploads releases, writes .env, migrates, restarts.
            deploy = {
              isSystemUser = true;
              group = "deploy";
              extraGroups = [ "kodai" ];
              home = "/var/lib/deploy";
              createHome = true;
              shell = pkgs.bashInteractive;
              # Options are comma-separated: a key line with options of its
              # own (from="...") gets restrict added to them.
              openssh.authorizedKeys.keys = map (
                key: if startsWithKeyType key then "restrict ${key}" else "restrict,${key}"
              ) deployKeys;
            };
          };
        };

        zep.ssh.options.extraAllowGroups = [ "deploy" ];

        # setgid directories: whatever deploy puts in them belongs to the
        # kodai group, so the app can read it.
        systemd.tmpfiles.rules = [
          # o+x: nginx may pass through, not list.
          "d ${dir} 0751 deploy kodai -"
          "d ${dir}/releases 2751 deploy kodai -"
          "d ${dir}/shared 2750 deploy kodai -"
          "d ${dir}/shared/var 2770 kodai kodai -"
        ];

        # The two root actions a deploy needs, and nothing else.
        security.polkit.enable = true;
        security.polkit.extraConfig = ''
          polkit.addRule(function (action, subject) {
            if (action.id == "org.freedesktop.systemd1.manage-units" && subject.user == "deploy") {
              var unit = action.lookup("unit"), verb = action.lookup("verb");
              if ((unit == "kodai.target" && verb == "restart") ||
                  (unit == "phpfpm-kodai.service" && verb == "reload")) {
                return polkit.Result.YES;
              }
            }
          });
        '';

        services = {
          # A deploy's reload lets running requests finish (up to 10s)
          # instead of cutting them off (a global setting, not the pool's).
          phpfpm.settings.process_control_timeout = "10s";
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

          # As Kodai's docker/nginx/default.conf, from the live release.
          # $realpath_root: PHP sees the release's real path, so switching
          # `current` never mixes two releases within a request.
          nginx = {
            enable = true;
            # Uploads up to php.ini's 50M (nginx's own default is 10M).
            clientMaxBodySize = "50m";
            recommendedOptimisation = true;
            recommendedGzipSettings = true;
            recommendedProxySettings = true;
            virtualHosts.kodai = {
              default = true;
              serverName = lib.mkIf (domain != null) domain;
              useACMEHost = lib.mkIf https domain;
              forceSSL = https;
              root = "${dir}/current/public";
              extraConfig = "index index.php;";
              locations = {
                "/".tryFiles = "$uri $uri/ /index.php?$query_string";
                "~ \\.php$".extraConfig = ''
                  try_files $uri =404;
                  include ${config.services.nginx.package}/conf/fastcgi_params;
                  fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
                  fastcgi_param DOCUMENT_ROOT $realpath_root;
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
            settings.mysqld.skip-networking = true;
            ensureDatabases = [ "kodai" ];
            ensureUsers = [
              {
                name = "kodai";
                ensurePermissions."kodai.*" = "SELECT, INSERT, UPDATE, DELETE";
              }
              {
                name = "deploy";
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
        ]
        ++ lib.optional https 443;

        age.secrets.cloudflare-dns = lib.mkIf https { file = dnsToken; };

        security.acme = lib.mkIf https {
          acceptTerms = true;
          certs.${domain} = {
            dnsProvider = "cloudflare";
            # Resolve the challenge record through Cloudflare itself, not the
            # tailnet's DNS.
            dnsResolver = "1.1.1.1:53";
            credentialFiles.CLOUDFLARE_DNS_API_TOKEN_FILE = config.age.secrets.cloudflare-dns.path;
            inherit (config.services.nginx) group;
          };
        };

        systemd = {
          targets.kodai = {
            description = "Kodai's workers and scheduler";
            wantedBy = [ "multi-user.target" ];
          };

          services = {
            kodai-scheduler = worker "Kodai scheduler" "schedule:work";

            # Kodai's PHP-FPM pool, sandboxed as far as a service that starts
            # as root and switches to kodai allows.
            phpfpm-kodai.serviceConfig = {
              UMask = "0007";
              ProtectSystem = "full";
              ProtectHome = true;
              PrivateTmp = true;
              ProtectKernelTunables = true;
              ProtectKernelModules = true;
              ProtectKernelLogs = true;
              ProtectControlGroups = true;
              RestrictNamespaces = true;
              LockPersonality = true;
            };
          }
          // lib.listToAttrs (
            map (
              queue:
              lib.nameValuePair "kodai-worker-${queue}" (
                worker "Kodai queue worker (${queue})" (
                  "queue:work" + lib.optionalString (queue != "default") " --queue=${queue}"
                )
              )
            ) queues
          );
        };

        # For the deploy (composer, migrations, bin/kodai) and for me.
        environment.systemPackages = [
          php
          php.packages.composer
        ];
      };
    };
}
