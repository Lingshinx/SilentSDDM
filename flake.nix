{
  description = "A very customizable SDDM theme that actually looks good";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({
        self,
        config,
        withSystem,
        flake-parts-lib,
        ...
      } @ top: {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        flake.nixosModules.default = flake-parts-lib.importApply ./module.nix {inherit self;};
        perSystem = {pkgs, ...}: {
          packages.default = pkgs.callPackage ./. {
            gitRev = self.rev or self.dirtyRev or "unknown";
          };
        };
      });
}
