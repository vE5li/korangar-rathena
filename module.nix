{
  pkgs,
  lib,
}:

{
  # options.services.rathena = {
  #   enable = lib.mkEnableOption "rathena service";
  # };
  options = {};

  config = {
    users.groups.rathena = {};
    users.users.rathena = {
      isSystemUser = true;
      group = "rathena";
      description = "User for rathena";
      home = "/rathena";
      createHome = true;
    };

    systemd.services.rathena-database = {
      enable = true;

      serviceConfig = {
        ExecStart = "${lib.getExe' pkgs.rathena-scripts "rathena-start-database"}";
        ExecStartPost = "${lib.getExe' pkgs.rathena-scripts "rathena-setup-database"}";
        User = "rathena";
        Group = "rathena";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    systemd.services.rathena-login-server = {
      enable = true;

      serviceConfig = {
        ExecStart = "${pkgs.rathena}/login-server";
        User = "rathena";
        Group = "rathena";
        Restart = "on-failure";
        RestartSec = 10;
      };

      unitConfig = {
        Wants = "rathena-database.service";
        After = "rathena-database.service";
      };
    };

    systemd.services.rathena-char-server = {
      enable = true;

      serviceConfig = {
        ExecStart = "${pkgs.rathena}/char-server";
        User = "rathena";
        Group = "rathena";
        Restart = "on-failure";
        RestartSec = 10;
      };

      unitConfig = {
        Wants = "rathena-login-server.service";
        After = "rathena-login-server.service";
      };
    };

    systemd.services.rathena-map-server = {
      enable = true;

      serviceConfig = {
        ExecStart = "${pkgs.rathena}/map-server";
        User = "rathena";
        Group = "rathena";
        Restart = "on-failure";
        RestartSec = 10;
      };

      unitConfig = {
        Wants = "rathena-char-server.service";
        After = "rathena-char-server.service";
      };

      wantedBy = [ "multi-user.target" ];
    };

    networking.firewall = {
      allowedTCPPorts = [ 6900 5121 6121 ];
    };
  };
}
