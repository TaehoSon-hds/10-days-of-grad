{
  description = "10-days-of-grad";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

  };

  outputs =
    inputs@{ self, nixpkgs, flake-utils, ... }:
    {
      overlay = nixpkgs.lib.composeManyExtensions [
                  (import ./overlay.nix)
                ];
    } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {};
        overlays = [ self.overlay ];
      };
    in {
      packages = {
        default = pkgs.myHaskellPackages.ten-days-of-grad;
      };

      devShells = {
        default = import ./develop.nix {
          inherit pkgs;
        };
      };
    }
  );
}
