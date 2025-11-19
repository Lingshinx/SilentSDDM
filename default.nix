{
  lib,
  stdenvNoCC,
  kdePackages,
  qt6,
  makeWrapper,
  symlinkJoin,
  gitRev ? "unknown",
  theme ? "default",
  extraBackgrounds ? [],
  extraConfigs ? [],
  # override the below to false if not on wayland (only matters for test script)
  withWayland ? true,
  withLayerShellQt ? true,
}: let
  inherit
    (lib)
    concatStringsSep 
    cleanSource
    licenses
    attrValues
    substring
    optional
    length
    ;

  inherit (stdenvNoCC) mkDerivation;

  propagatedBuildInputs = with kdePackages; [
    qtmultimedia
    qtsvg
    qtvirtualkeyboard
  ];

  sddm-wrapped = kdePackages.sddm.override {
    extraPackages =
      propagatedBuildInputs
      ++ optional withWayland qt6.qtwayland
      ++ optional withLayerShellQt kdePackages.layer-shell-qt;
  };
in
  mkDerivation (final: {
    inherit propagatedBuildInputs;

    pname = "silent";
    version = "${substring 0 8 gitRev}";
    src = cleanSource ./.;

    dontWrapQtApps = true;

    installPhase = let
      basePath = "$out/share/sddm/themes/${final.pname}";
      notEmpty = list: length list != 0;
    in concatStringsSep "\n" ([''
      mkdir -p ${basePath}
      cp -r $src/* ${basePath}

      chmod +w ${basePath}/metadata.desktop
      echo 'ConfigFile=configs/${theme}.conf' >> ${basePath}/metadata.desktop
      ''] ++ optional (notEmpty extraBackgrounds) ''
      chmod -R +w ${basePath}/backgrounds
      cp ${toString extraBackgrounds} ${basePath}/backgrounds/
      '' ++ optional (notEmpty extraConfigs) ''
      chmod -R +w ${basePath}/configs
      cp ${toString extraConfigs} ${basePath}/configs/
      '');

    passthru.test = symlinkJoin {
      name = "test-sddm-silent";
      paths = [sddm-wrapped];
      nativeBuildInputs = [makeWrapper];
      postBuild = ''
        makeWrapper $out/bin/sddm-greeter-qt6 $out/bin/test-sddm-silent \
          --suffix QML2_IMPORT_PATH ':' ${final.finalPackage}/share/sddm/themes/${final.pname}/components \
          --set QT_IM_MODULE qtvirtualkeyboard \
          --add-flags '--test-mode --theme ${final.finalPackage}/share/sddm/themes/${final.pname}'
      '';
    };

    meta.licenses = licenses.gpl3;
  })
