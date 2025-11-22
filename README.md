# Readme

Forked from [uiriansan/SilentSDDM](https://github.com/uiriansan/SilentSDDM)

The git repo is lightweight -- only about 1.7MB, fast to clone and taking no space

## Installation

```nix
{pkgs, inputs, ...}: {
  imports = [inputs.silentSDDM.nixosModules.default];

  qt.enable = true;
  services.displayManager.sddm = {
    enable = true;
    theme = "silent";
    silent = {
      theme = <file-to-your-config>;
      extraBackgrounds = [<file-to-your-backgrounds>];
    };
  };
}
```
