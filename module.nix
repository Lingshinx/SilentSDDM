{pkgs, config, lib, inputs, ...}:

with builtins;
with lib;
with types;

{
  options.services.displayManager.sddm.silent = {
    theme = mkOption {
      type = nullOr path;
      default = null;
      description = ''
        SilentSDDM config file
        '';
    };

    extraBackgrounds = mkOption {
      type = listOf path;
      default = [];
      description = ''
        Background be used in config file, can be image or mp4
      '';
    };
  };

  config = let
    silent = config.services.displayManager.sddm.silent;
    theme = config.services.displayManager.sddm.theme;
    enabled = theme == silent-sddm.pname;
    silent-sddm = inputs.silentSDDM.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      inherit (silent) theme extraBackgrounds;
    };
  in mkIf enabled {
    environment.systemPackages = [silent-sddm];
    services.displayManager.sddm = {
      extraPackages = silent-sddm.propagatedBuildInputs;
      settings.General = {
        GreeterEnvironment = "QML2_IMPORT_PATH=${silent-sddm}/share/sddm/themes/${silent-sddm.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
        InputMethod = "qtvirtualkeyboard";
      };
    };
  };
}
