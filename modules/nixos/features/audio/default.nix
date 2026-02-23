# Audio configuration
# Sets up PipeWire for sound
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.features;
in {
  options.features = {
      audio = lib.mkEnableOption "Audio/PipeWire";
  };

  config = lib.mkIf cfg.audio {
      # Disable PulseAudio, enable PipeWire
      hardware.pulseaudio.enable = false;

      # RealtimeKit for audio permissions
      security.rtkit.enable = true;

      # PipeWire configuration
      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        jack.enable = true;
      };

      security.wrappers.ffmpeg = {
        owner = "root";
        group = "video";
        capabilities = "cap_sys_admin+ep";
        source = "${pkgs.ffmpeg}/bin/ffmpeg";
      };

      # Additional audio packages
      environment.systemPackages = with pkgs; [
        pavucontrol
        pulseaudio # for pactl command
      ];

  };
}
