{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  pkg-config,
  doxygen,
  qt6Packages,
  lshw,
  libuchardet,
  dtkcommon,
  dtk6log,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dtk6core";
  version = "6.0.19";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dtk6core";
    rev = finalAttrs.version;
    hash = "sha256-3MwvTnjtVVcMjQa1f4UdagEtWhJj8aDgfUlmnGo/R7s=";
  };

  patches = [
    ./fix-pkgconfig-path.patch
    ./fix-pri-path.patch
    (fetchpatch {
      name = "fix-build-on-qt-6.8.patch";
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/dtk6core/-/raw/d2e991f96b2940e8533b7e944bab5a7dd6aa0fb7/qt-6.8.patch";
      hash = "sha256-HZxUrtUmVwnNUwcBoU7ewb+McsRkALQglPBbJU8HTkk=";
    })
  ];

  postPatch = ''
    substituteInPlace misc/DtkCoreConfig.cmake.in \
      --subst-var-by PACKAGE_TOOL_INSTALL_DIR ${placeholder "out"}/libexec/dtk6/DCore/bin
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    doxygen
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  dontWrapQtApps = true;

  buildInputs = [
    qt6Packages.qtbase
    lshw
    libuchardet
  ];

  propagatedBuildInputs = [
    dtkcommon
    dtk6log
  ];

  cmakeFlags = [
    "-DDTK_VERSION=${finalAttrs.version}"
    "-DBUILD_DOCS=ON"
    "-DBUILD_EXAMPLES=OFF"
    "-DQCH_INSTALL_DESTINATION=${placeholder "doc"}/share/doc"
    "-DDSG_PREFIX_PATH='/run/current-system/sw'"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DD_DSG_APP_DATA_FALLBACK=/var/dsg/appdata"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${lib.getBin qt6Packages.qtbase}/${qt6Packages.qtbase.qtPluginPrefix}
  '';

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  postFixup = ''
    for binary in $out/libexec/dtk6/DCore/bin/*; do
      wrapQtApp $binary
    done
  '';

  meta = {
    description = "Deepin tool kit core library";
    homepage = "https://github.com/linuxdeepin/dtk6core";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = lib.teams.deepin.members;
  };
})
