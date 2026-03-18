{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    {
      overlays.default = final: prev: {
        rathena = final.callPackage ./rathena.nix {};
        rathena-scripts = final.callPackage ./scripts.nix {};
        rathena-test-20120307 = final.callPackage ./test.nix {PACKETVER = "20120307";};
        rathena-test-20220406 = final.callPackage ./test.nix {PACKETVER = "20220406";};
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = (import nixpkgs) {
          inherit system;
          overlays = [self.overlays.default];
        };
      in {
        formatter = pkgs.alejandra;

        packages = {
          inherit (pkgs) rathena rathena-scripts rathena-test-20120307 rathena-test-20220406;
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
