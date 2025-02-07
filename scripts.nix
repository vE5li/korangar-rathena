{
  pkgs,
  writeShellScriptBin,
  lib,
  rathena,
}:

let
  mysql-commands = pkgs.writeText "commands" ''
    CREATE USER 'ragnarok'@'localhost' IDENTIFIED BY 'ragnarok';
    GRANT ALL PRIVILEGES ON `ragnarok`.* TO 'ragnarok'@'localhost' IDENTIFIED BY 'ragnarok';
    FLUSH PRIVILEGES;

    CREATE DATABASE ragnarok;
  '';

  rathena-start-database = writeShellScriptBin "rathena-start-database" ''
    ${lib.getExe' pkgs.mariadb "mariadb-install-db"} --datadir=/home/rathena/database/
    ${lib.getExe' pkgs.mariadb "mariadbd-safe"} --datadir=/home/rathena/database/ --socket=/home/rathena/database/mysqld.sock --pid-file=/home/rathena/database/mysqld.pid --user=rathena
  '';

  rathena-setup-database = writeShellScriptBin "rathena-setup-database" ''
    until ${lib.getExe' pkgs.mariadb "mariadb-admin"} ping --socket=/home/rathena/database/mysqld.sock --silent; do
      echo "Waiting for Database to start..."
      sleep 1
    done

    RESULT=$(${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock --user=rathena -sN -e "SELECT COUNT(*) FROM mysql.user WHERE User='ragnarok';")

    if [ "$RESULT" -gt 0 ]; then
        echo "Database is already installed"
    else
        echo "Database is not yet set up. Installing..."

        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena < ${mysql-commands}

        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena -D ragnarok < ${rathena}/sql-files/main.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena -D ragnarok < ${rathena}/sql-files/logs.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena -D ragnarok < ${rathena}/sql-files/item_db.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena -D ragnarok < ${rathena}/sql-files/item_db2.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena -D ragnarok < ${rathena}/sql-files/item_db_re.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena -D ragnarok < ${rathena}/sql-files/item_db2_re.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena -D ragnarok < ${rathena}/sql-files/mob_db.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena -D ragnarok < ${rathena}/sql-files/mob_db2.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena -D ragnarok < ${rathena}/sql-files/mob_db_re.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena -D ragnarok < ${rathena}/sql-files/mob_skill_db.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena -D ragnarok < ${rathena}/sql-files/mob_skill_db2.sql
        ${lib.getExe' pkgs.mariadb "mariadb"} --socket=/home/rathena/database/mysqld.sock -u rathena -D ragnarok < ${rathena}/sql-files/mob_skill_db_re.sql
    fi
  '';
in pkgs.symlinkJoin {
  inherit (rathena) name;

  paths = [
    rathena-start-database
    rathena-setup-database
  ];
}
