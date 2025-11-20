{
  description = "A very customizable SDDM theme that actually looks good";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    # unsure if we need to include darwin but no harm in doing so
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs {inherit system;}));
  in {
    nixosModules.silent-sddm = ./module.nix;
    packages = forAllSystems (pkgs: rec {
      # you may test these themes with `nix run .#default.test`
      # similiarly `nix run .#example.test` will work too
      default = pkgs.callPackage ./default.nix {
        # accurate versioning based on git rev for non tagged releases
        gitRev = self.rev or self.dirtyRev or "unknown";
      };

      # here to not break the old test package
      test = default.test;
    });
  };
}
