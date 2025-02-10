{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, nixpkgs }:
    {
      overlays.default = final: prev: {
        rathena = final.callPackage ./rathena.nix {};
        rathena-scripts = final.callPackage ./scripts.nix {};
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in
      {
        packages = {
          inherit (pkgs) rathena rathena-scripts;
          default = pkgs.rathena;
        };

        nixosModules = {
          default = import ./module.nix {
            inherit pkgs;
            inherit (nixpkgs) lib;
          };
        };
      }
    );
}
