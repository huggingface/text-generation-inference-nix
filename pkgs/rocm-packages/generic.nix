{
  lib,
  autoPatchelfHook,
  callPackage,
  fetchurl,
  stdenv,
  dpkg,
  rsync,
  rocmPackages,

  pname,
  version,

  # List of string-typed dependencies.
  deps,

  # List of derivations that must be merged.
  components,
}:

let
  filteredDeps = lib.filter (
    dep:
    !builtins.elem dep [
      "amdgpu-core"
      "libdrm-amdgpu-common"
      "libdrm-amdgpu-amdgpu1"
      "libdrm-amdgpu-radeon1"
      "libdrm-amdgpu-dev"
      "libdrm2-amdgpu"
    ]
  ) deps;
  srcs = map (component: fetchurl { inherit (component) url sha256; }) components;
in
stdenv.mkDerivation rec {
  inherit pname version srcs;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    rocmPackages.markForRocmRootHook
    rsync
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    stdenv.cc.cc.libgcc
  ] ++ (map (dep: rocmPackages.${dep}) filteredDeps);

  # dpkg hook does not seem to work for multiple sources.
  unpackPhase = ''
    for src in $srcs; do
      dpkg-deb -x "$src" .
    done
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -rT opt/rocm-* $out
    runHook postInstall
  '';

  autoPatchelfIgnoreMissingDeps = [
    # Not sure where this comes from, not in the distribution.
    "amdpythonlib.so"

    # Should come from the driver runpath.
    "libOpenCL.so.1"

    # Distribution only has libamdhip64.so.6? Only seems to be used
    # by /bin/roofline-* for older Linux distributions.
    "libamdhip64.so.5"

    # Python 3.8 is not in nixpkgs anymore.
    "libpython3.8.so.1.0"
  ];
}
