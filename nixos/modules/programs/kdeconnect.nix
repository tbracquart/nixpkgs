{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.programs.kdeconnect = {
    enable = lib.mkEnableOption ''
      kdeconnect.

      Note that it will open the TCP and UDP port from
      1714 to 1764 as they are needed for it to function properly.
      You can use the {option}`package` to use
      `gnomeExtensions.gsconnect` as an alternative
      implementation if you use Gnome
    '';
    package = lib.mkPackageOption pkgs [ "kdePackages" "kdeconnect-kde" ] {
      nullable = true;
      example = "gnomeExtensions.gsconnect";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to open the TCP and UDP ports (1714-1764) needed by
        KDE Connect. Useful to disable when the package itself is
        installed elsewhere (e.g. via Home Manager) and only the
        system-level firewall rule is needed here.
      '';
    };
  };
  config =
    let
      cfg = config.programs.kdeconnect;
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = lib.optionals (cfg.package != null) [
        cfg.package
      ];
      networking.firewall = lib.mkIf cfg.openFirewall (rec {
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
        allowedUDPPortRanges = allowedTCPPortRanges;
      });
    };
}
