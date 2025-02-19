{
  lib,

  autoAddDriverRunpath,
  buildPythonPackage,
  cmake,
  cudaPackages,
  ninja,
  toml2cmake,

  torch,
}:

{
  pname,
  version,
  src,

  cutlass ? null,
}:

buildPythonPackage rec {
  inherit pname version src;

  nativeBuildInputs = [
    autoAddDriverRunpath
    cmake
    cudaPackages.cuda_nvcc
    ninja
  ];

  buildInputs = [
    torch.cxxdev
  ] ++ lib.optionals (cutlass != null) [ cutlass ];

  dependencies = [
    torch
  ];

  postPatch = ''
    ${toml2cmake}/bin/toml2cmake generate-torch build.toml
  '';

  # cmake/ninja are used for parallel builds, but we don't want the
  # cmake configure hook to kick in.
  dontUseCmakeConfigure = true;

  env = {
    CUDA_HOME = "${lib.getDev cudaPackages.cuda_nvcc}";
    # Ideally this should be the longest capabilities list in build.toml,
    # but this is a good approximation for now.
    NVCC_THREADS = builtins.length torch.cudaCapabilities;
    TORCH_CUDA_ARCH_LIST = lib.concatStringsSep ";" torch.cudaCapabilities;
  };

  # Tests require CUDA.
  doCheck = false;

  pythonImportsCheck = [ "${lib.replaceStrings [ "-" ] [ "_" ] pname}" ];
}
