{
  pkgs,
  stdenv,
  fetchFromGitHub,
  PACKETVER ? "20220406",
}:

stdenv.mkDerivation rec {
  pname = "rathena";
  version = "58f09251023775381630e98083b18c236a75f1b8";

  nativeBuildInputs = with pkgs; [
    zlib
    getopt
  ];

  buildInputs = with pkgs; [
    libmysqlclient
    mariadb
  ];

  configureFlags = [
    "--enable-packetver=${PACKETVER}"
  ];

  patches = [
    # Everyone can alwyas use @-commands
    ./patches/at-command.patch
    # Increase attack speed cap
    ./patches/attack-speed.patch
    # Allow instant deletion of any character
    ./patches/character-deletion.patch
    # Don't use pincodes for securing the accounts
    ./patches/disable-pin-code.patch
    # Increase drop rates massively
    ./patches/drop-rates.patch
    # Allow account creation with `_m` and `_f`
    ./patches/new-account.patch
    # Disable packet obfuscation
    ./patches/packet-obfuscation.patch
    # Always allow unlimited slot moves
    ./patches/unlimited-slot-moves.patch
  ];

  preInstall = ''
    # Change install path to our store path
    sed -i "s@INST_PATH=/opt@INST_PATH=$out/@" function.sh

    # Change PKG_PATH since it can't be passed over the `--destdir` argument
    sed -i "s@PKG_PATH=@PKG_PATH=$out\n#@" function.sh
  '';

  postInstall = ''
    cp sql-files $out/sql-files -r
  '';

  src = fetchFromGitHub {
    owner = "ve5li";
    repo = "rathena";
    rev = version;
    hash = "sha256-NZK389dPFrhrlQe1KEYYkEtcm4h4DOwuIEMHiYv8TuM=";
  };
}
