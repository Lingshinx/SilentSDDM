{
  lib,
  stdenvNoCC,
  kdePackages,
  qt6,
  makeWrapper,
  symlinkJoin,
  gitRev ? "unknown",
  theme ? ./configs/default.conf,
  extraBackgrounds ? [],
  # override the below to false if not on wayland (only matters for test script)
  withWayland ? true,
  withLayerShellQt ? true,
}: let
  inherit
    (lib)
    cleanSource
    licenses
    substring
    optional
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
    inherit theme extraBackgrounds;
    installPhase = let
      basePath = "$out/share/sddm/themes/${final.pname}";
    in
      # bash
      ''
        mkdir -p ${basePath}
        cp -r $src/* ${basePath}

        if test -n "$theme"; then
          chmod +w ${basePath}/configs/default.conf
          cp $theme ${basePath}/configs/default.conf
        fi
        chmod +w ${basePath}/backgrounds/
        for bg in $extraBackgrounds; do
          cp "$bg" "${basePath}/backgrounds/$(stripHash "$bg")"
        done
      '';

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

    meta.license = licenses.gpl3;
  })
