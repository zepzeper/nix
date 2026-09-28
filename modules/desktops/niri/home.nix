{
  # niri with the Noctalia shell: the user half (see niri.nix for the system
  # half, theme.nix for GTK/Qt/cursor/icons). Given to every Home Manager
  # user, active only on machines whose desktop is niri.
  #
  # - niri's config: the files in config/, plus outputs.kdl generated from
  #   the host's zep.niri.options.outputs. Checked together with
  #   `niri validate` when the system is built, so a typo fails the build
  #   instead of the session. Each file is linked on its own, so
  #   ~/.config/niri stays writable for Noctalia's noctalia.kdl and your
  #   local.kdl.
  # - Noctalia: bar, launcher, notifications, lock screen, idle, wallpaper,
  #   OSD, clipboard history, screenshots, night light, session menu, polkit
  #   dialog, and the colours of other apps. Settings: noctalia.toml. Runs as
  #   a systemd user service tied to the niri session and restarts when its
  #   settings change.
  # - ghostty, the terminal, coloured by Noctalia.
  flake.modules.homeManager.desktops-niri =
    {
      config,
      lib,
      pkgs,
      options,
      osConfig,
      ...
    }:
    let
      desktop = osConfig.zep.desktop;
      active = desktop.enable && desktop.options.environment == "niri";

      niriFiles = builtins.attrNames (builtins.readDir ./config) ++ [ "outputs.kdl" ];

      niriConfig = pkgs.runCommand "niri-config" { } ''
        mkdir -p $out
        cp ${./config}/*.kdl $out/
        cp ${pkgs.writeText "outputs.kdl" osConfig.zep.niri.options.outputs} $out/outputs.kdl
        ${lib.getExe osConfig.programs.niri.package} validate -c $out/config.kdl
      '';

      noctalia = config.programs.noctalia.package;
      ghosttyTheme = "${config.xdg.configHome}/ghostty/themes/noctalia";
    in
    {
      key = "zep#hm-desktops-niri";
      config = lib.mkIf active (
        lib.mkMerge [
          {
            xdg.configFile = lib.listToAttrs (
              map (file: lib.nameValuePair "niri/${file}" { source = "${niriConfig}/${file}"; }) niriFiles
            );

            programs.ghostty = {
              enable = true;
              settings = {
                font-family = "JetBrainsMonoNL Nerd Font Mono";
                font-size = 12;
                # Colours: the theme Noctalia renders from its palette. "?"
                # makes it optional, so ghostty (and Home Manager's check of
                # this config) is fine before Noctalia has written it once.
                config-file = "?${ghosttyTheme}";
                window-decoration = "none";
                gtk-titlebar = false;
                confirm-close-surface = false;
                keybind = [ "ctrl+enter=unbind" ];
              };
            };

            home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
            fonts.fontconfig.enable = true;
          }

          # Home Manager's Noctalia module exists on the unstable channel
          # only; niri.nix already refuses niri on stable.
          (lib.optionalAttrs (options.programs ? noctalia) {
            programs.noctalia = {
              enable = true;
              systemd.enable = true;
              settings = lib.recursiveUpdate (builtins.fromTOML (builtins.readFile ./noctalia.toml)) {
                # Noctalia's built-in ghostty template would edit ghostty's
                # config file, which is read-only here. This user template
                # renders the same colours to the file ghostty includes
                # (config-file above) and reloads ghostty, touching nothing
                # else.
                theme.templates.user.ghostty = {
                  input_path = "${noctalia}/share/noctalia/assets/templates/ghostty/ghostty";
                  output_path = ghosttyTheme;
                  post_hook = "bash ${noctalia}/share/noctalia/assets/templates/ghostty/reload.sh";
                };
              };
            };
          })
        ]
      );
    };
}
