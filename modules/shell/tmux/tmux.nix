{ inputs, ... }:
{
  # tmux on every machine, with tmux-sessionizer and the cheat script. The
  # files themselves live next to this one and are edited as files:
  #
  #   tmux.conf          the tmux config (becomes /etc/tmux.conf)
  #   scripts/cheat      cht.sh cheat sheet (prefix i), with its lists in
  #                      scripts/resources/
  #
  # This file only installs them. tmux-sessionizer is ThePrimeagen's script,
  # unchanged, from the `tmux-sessionizer` flake input. Which folders it
  # offers is a personal setting (modules/users/<name>/).
  flake.modules.nixos.shell-tmux =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      tmux = config.programs.tmux.package;

      # Installs a script as-is, together with the folder it sits in (for
      # files next to it), and puts the programs it calls on its PATH.
      script =
        {
          name,
          dir,
          path,
        }:
        pkgs.runCommand name { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
          mkdir -p $out/libexec
          cp -r ${dir} $out/libexec/${name}
          chmod +x $out/libexec/${name}/${name}
          makeWrapper $out/libexec/${name}/${name} $out/bin/${name} \
            --prefix PATH : ${lib.makeBinPath path}
        '';

      tmux-sessionizer = script {
        name = "tmux-sessionizer";
        dir = inputs.tmux-sessionizer;
        path = [
          tmux
          pkgs.fzf
          pkgs.findutils
          pkgs.coreutils
          pkgs.gnugrep
          pkgs.procps
        ];
      };

      cheat = script {
        name = "cheat";
        dir = ./scripts;
        path = [
          tmux
          pkgs.fzf
          pkgs.coreutils
          pkgs.gnugrep
        ];
      };
    in
    {
      key = "zep#shell-tmux";
      options.zep.tmux.enable = lib.mkEnableOption "tmux with tmux-sessionizer";

      config = lib.mkIf config.zep.tmux.enable {
        programs.tmux = {
          enable = true;
          extraConfig = builtins.readFile ./tmux.conf;
        };

        environment.systemPackages = [
          tmux-sessionizer
          cheat
          # What cheat's windows run: those start in tmux's environment, not
          # the script's, so these have to be on the system PATH.
          pkgs.curl
          pkgs.w3m-batch
          pkgs.less
        ];

        # After oh-my-zsh, which picks the emacs keymap: bound earlier, Ctrl+F
        # would land in the vi keymap zsh starts in when EDITOR is nvim.
        programs.zsh.interactiveShellInit = lib.mkIf config.zep.zsh.enable (
          lib.mkAfter ''
            bindkey -M emacs -s '^f' "tmux-sessionizer\n"
          ''
        );
      };
    };
}
