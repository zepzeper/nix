{
  # A small security baseline that costs the user nothing: firewall on, sudo
  # only for wheel, and kernel settings that hide information an attacker
  # would use. Anything that can get in the way (USB blocking, AppArmor
  # profiles) belongs in its own opt-in block, not here.
  flake.modules.nixos.base-hardening =
    { config, lib, ... }:
    let
      cfg = config.zep.hardening;
      # Above nixpkgs' own defaults (mkDefault, 1000), below a plain host
      # setting (100), so a host can still change one without mkForce.
      soft = lib.mkOverride 900;
    in
    {
      key = "zep#base-hardening";
      options.zep.hardening = {
        enable = lib.mkEnableOption "baseline hardening (firewall, sudo, sysctl)";
      };

      config = lib.mkIf cfg.enable {
        networking.firewall.enable = lib.mkForce true;

        security.sudo.execWheelOnly = lib.mkForce true;

        boot.kernel.sysctl = {
          # Kernel pointers and the kernel log are for root only.
          "kernel.kptr_restrict" = soft 2;
          "kernel.dmesg_restrict" = soft 1;
          # Only a parent process can ptrace its children.
          "kernel.yama.ptrace_scope" = soft 1;
          # Protect against link and FIFO tricks in world-writable dirs.
          "fs.protected_symlinks" = soft 1;
          "fs.protected_hardlinks" = soft 1;
          "fs.protected_fifos" = soft 2;
          "fs.protected_regular" = soft 2;
          # No ICMP redirects or source routing. "default" covers interfaces
          # that appear later (WiFi, VPN, docks), "all" the ones up at boot.
          "net.ipv4.conf.all.accept_redirects" = soft 0;
          "net.ipv4.conf.default.accept_redirects" = soft 0;
          "net.ipv4.conf.all.send_redirects" = soft 0;
          "net.ipv4.conf.default.send_redirects" = soft 0;
          "net.ipv4.conf.all.accept_source_route" = soft 0;
          "net.ipv4.conf.default.accept_source_route" = soft 0;
          "net.ipv6.conf.all.accept_redirects" = soft 0;
          "net.ipv6.conf.default.accept_redirects" = soft 0;
          "net.ipv6.conf.all.accept_source_route" = soft 0;
          "net.ipv6.conf.default.accept_source_route" = soft 0;
          "net.ipv4.tcp_syncookies" = soft 1;
        };
      };
    };
}
