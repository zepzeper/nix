{
  # zsh, the admins' login shell on every machine, configured system-wide so
  # a server without Home Manager gets the same shell as the desktop.
  # Ported from the zsh setup in zepzeper/dev:
  #
  # - oh-my-zsh with the robbyrussell theme and its git and fzf plugins
  #   (Ctrl+R searches history with fzf, Ctrl+T picks files, Alt+C cds);
  # - suggestions from history as you type, and syntax highlighting;
  # - `cat` is bat (what the zsh-bat plugin did), `command cat` for the real
  #   one;
  # - the machine's name in front of the prompt, green where there is a
  #   desktop and red on a server, so a shell on a server is hard to mistake
  #   for your own.
  #
  # Home Manager's session variables (EDITOR and friends) are read in too:
  # Home Manager only does that itself for shells it manages, and this one is
  # managed here. People (employees) keep bash.
  flake.modules.nixos.shell-zsh =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.zep.zsh;
      admins = lib.attrNames config.zep.users.options.admins;
      hostColour = if config.zep.desktop.enable then "green" else "red";
    in
    {
      key = "zep#shell-zsh";
      options.zep.zsh.enable = lib.mkEnableOption "zsh as the admins' login shell";

      config = lib.mkIf cfg.enable {
        programs.zsh = {
          enable = true;

          ohMyZsh = {
            enable = true;
            theme = "robbyrussell";
            plugins = [
              "git"
              "fzf"
            ];
          };
          # oh-my-zsh sets up completion itself; a second compinit only
          # slows every shell start.
          enableGlobalCompInit = false;
          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;

          shellAliases.cat = "bat --paging=never";

          shellInit = ''
            hm_vars="/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
            [ -r "$hm_vars" ] && . "$hm_vars"
            unset hm_vars
          '';

          # After oh-my-zsh, which sets the theme's prompt.
          interactiveShellInit = lib.mkAfter ''
            PROMPT="%F{${hostColour}}[%m]%f $PROMPT"
          '';
        };

        environment.systemPackages = [
          pkgs.bat
          pkgs.fzf
        ];

        users.users = lib.genAttrs admins (_: {
          shell = pkgs.zsh;
        });

        # Everything lives in /etc/zshrc. An (empty) ~/.zshrc keeps zsh's
        # first-run wizard away; one that already exists is left alone.
        systemd.tmpfiles.rules = map (
          name: "f ${config.users.users.${name}.home}/.zshrc 0644 ${name} users -"
        ) admins;
      };
    };
}
