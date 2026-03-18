{
  pkgs,
  lib,
  PACKETVER,
}: let
  database-directory = "/tmp/rathena-test";

  rathena = pkgs.callPackage ./rathena.nix {
    inherit pkgs;
    stdenv = pkgs.stdenv;
    fetchFromGitHub = pkgs.fetchFromGitHub;
    PACKETVER = PACKETVER;
  };

  rathena-scripts = pkgs.callPackage ./scripts.nix {
    inherit pkgs lib rathena database-directory;
    writeShellScriptBin = pkgs.writeShellScriptBin;
    database-user = "$USER";
  };
in
  pkgs.writeShellScriptBin "rathena-test-${PACKETVER}" ''
    set -e

    DB_PID=""
    LOGIN_PID=""
    CHAR_PID=""
    MAP_PID=""

    cleanup() {
      [ -n "$MAP_PID" ] && kill -9 $MAP_PID 2>/dev/null || true
      [ -n "$CHAR_PID" ] && kill -9 $CHAR_PID 2>/dev/null || true
      [ -n "$LOGIN_PID" ] && kill -9 $LOGIN_PID 2>/dev/null || true

      if [ -f "${database-directory}/mysqld.pid" ]; then
        MARIADB_PID=$(cat "${database-directory}/mysqld.pid")
        [ -n "$MARIADB_PID" ] && kill -9 "$MARIADB_PID" 2>/dev/null || true
      fi

      rm -rf "${database-directory}"
    }

    # Set up signal handlers
    trap cleanup EXIT INT TERM

    mkdir -p ${database-directory}
    cd "${database-directory}"

    ${lib.getExe' rathena-scripts "rathena-start-database"} &
    DB_PID=$!
    ${lib.getExe' rathena-scripts "rathena-setup-database"}

    wait_for_server() {
      local server_path=$1
      local ready_message=$2
      local log_file=${database-directory}/''${server_path##*/}.log

      $server_path > "$log_file" 2>&1 &
      local pid=$!

      while ! grep -q "$ready_message" "$log_file" 2> /dev/null; do
        sleep 0.1
      done

      echo $pid
    }

    LOGIN_PID=$(wait_for_server "${rathena}/login-server" "The login-server is ready")
    CHAR_PID=$(wait_for_server "${rathena}/char-server" "The char-server is ready")
    MAP_PID=$(wait_for_server "${rathena}/map-server" "Map Server is now online")

    echo "test rAthena is running"

    # Wait indefinitely until signal received
    wait
  ''
