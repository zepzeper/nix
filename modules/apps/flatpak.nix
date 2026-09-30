{
  # Flatpak with Flathub, so people can install apps themselves without an
  # admin: from Discover on Plasma or Software on GNOME (both appear once
  # Flatpak is on). Flatpak apps are sandboxed and live outside the system,
  # so nothing they install can break it, and they update from the app
  # store. Flathub is added on its own at boot.
  flake.modules.nixos.apps-flatpak =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      key = "zep#apps-flatpak";
      options.zep.flatpak.enable = lib.mkEnableOption "Flatpak with Flathub";

      config = lib.mkIf config.zep.flatpak.enable {
        services.flatpak.enable = true;

        # Flatpak's own policy asks an admin to install or remove apps
        # (updates are free); people at the machine may do it themselves.
        # Removing runtimes stays with admins: other apps may need them.
        security.polkit.extraConfig = ''
          polkit.addRule(function (action, subject) {
            if ((action.id == "org.freedesktop.Flatpak.app-install" ||
                 action.id == "org.freedesktop.Flatpak.runtime-install" ||
                 action.id == "org.freedesktop.Flatpak.app-uninstall") &&
                subject.local && subject.active) {
              return polkit.Result.YES;
            }
          });
        '';

        systemd.services.flatpak-flathub = {
          description = "Add the Flathub repository to Flatpak";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          path = [ pkgs.flatpak ];
          serviceConfig = {
            Type = "oneshot";
            # A laptop that boots offline tries again at the next boot.
            SuccessExitStatus = [ 1 ];
          };
          script = ''
            flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
          '';
        };
      };
    };
}
