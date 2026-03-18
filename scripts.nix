{
  pkgs,
  writeShellScriptBin,
  lib,
  rathena,
  database-directory ? "/rathena/database",
  database-user ? "rathena",
}: let
  socket-file = "${database-directory}/mysqld.sock";
  pid-file = "${database-directory}/mysqld.pid";

  mysql-commands = pkgs.writeText "commands" ''
    CREATE USER 'ragnarok'@'localhost' IDENTIFIED BY 'ragnarok';
    GRANT ALL PRIVILEGES ON `ragnarok`.* TO 'ragnarok'@'localhost' IDENTIFIED BY 'ragnarok';
    FLUSH PRIVILEGES;

    CREATE DATABASE ragnarok;
  '';

  rathena-start-database = writeShellScriptBin "rathena-start-database" ''
    ${lib.getExe' pkgs.mariadb "mariadb-install-db"} --datadir=${database-directory}
    ${lib.getExe' pkgs.mariadb "mariadbd-safe"} --datadir=${database-directory} --socket=${socket-file} --pid-file=${pid-file} --user=${database-user}
  '';

  rathena-setup-database = writeShellScriptBin "rathena-setup-database" ''
    until ${lib.getExe' pkgs.mariadb "mariadb-admin"} ping --socket=${socket-file} --silent; do
      echo "Waiting for Database to start..."
      sleep 1
    done

    RESULT=$(${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} --user=${database-user} -sN -e "SELECT COUNT(*) FROM mysql.user WHERE User='ragnarok';")

    if [ "$RESULT" -gt 0 ]; then
        echo "Database is already installed"
    else
        echo "Database is not yet set up. Installing..."

        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} < ${mysql-commands}

        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} -D ragnarok < ${rathena}/sql-files/main.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} -D ragnarok < ${rathena}/sql-files/logs.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} -D ragnarok < ${rathena}/sql-files/item_db.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} -D ragnarok < ${rathena}/sql-files/item_db2.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} -D ragnarok < ${rathena}/sql-files/item_db_re.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} -D ragnarok < ${rathena}/sql-files/item_db2_re.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} -D ragnarok < ${rathena}/sql-files/mob_db.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} -D ragnarok < ${rathena}/sql-files/mob_db2.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} -D ragnarok < ${rathena}/sql-files/mob_db_re.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} -D ragnarok < ${rathena}/sql-files/mob_skill_db.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} -D ragnarok < ${rathena}/sql-files/mob_skill_db2.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=${socket-file} -u ${database-user} -D ragnarok < ${rathena}/sql-files/mob_skill_db_re.sql
    fi
  '';
in
  pkgs.symlinkJoin {
    inherit (rathena) name;

    paths = [
      rathena-start-database
      rathena-setup-database
    ];
  }
