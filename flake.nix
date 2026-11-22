{
  description = "A very customizable SDDM theme that actually looks good";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        packages.default = pkgs.callPackage ./. {
          gitRev = self.rev or self.dirtyRev or "unknown";
        };
      }
    )
    // {
      nixosModules.default = import ./module.nix {inherit self;};
    };
}
