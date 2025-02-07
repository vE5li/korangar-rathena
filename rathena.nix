{
  pkgs,
  stdenv,
  fetchFromGitHub,
  PACKETVER ? "20220406",
}:

stdenv.mkDerivation rec {
  pname = "rathena";
  version = "2354fef32f4d04a089015dcb20f01e326b3c981b";

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
    owner = "rathena";
    repo = "rathena";
    rev = version;
    hash = "sha256-fr5MPCYgKR9Qenx6E5tYT2OxU84nESWO/10cUd8/aRA=";
  };
}
