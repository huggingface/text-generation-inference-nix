{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  autoAddDriverRunpath,
  cmake,
  git,
  ninja,
  packaging,
  psutil,
  which,
  cudaPackages,
  torch,
}:

buildPythonPackage rec {
  pname = "EETQ";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "NetEase-FuXi";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-LJejQUYKgy/1Pn1jEl3fX0+/OLevwWlb9sfPZ1cQMIA";
  };

  sourceRoot = "${src.name}";

  stdenv = cudaPackages.backendStdenv;

  buildInputs = with cudaPackages; [
    cuda_nvtx
    cuda_cccl
    cuda_cudart
    libcublas
    libcusolver
    libcusparse
    psutil
  ];

  nativeBuildInputs = [
    autoAddDriverRunpath
    cmake
    ninja
    which
  ];

  dependencies = [ torch ];

  env = {
    CUDA_HOME = "${lib.getDev cudaPackages.cuda_nvcc}";
    TORCH_CUDA_ARCH_LIST = lib.concatStringsSep ";" torch.cudaCapabilities;
  };

  propagatedBuildInputs = [ torch ];

  # cmake/ninja are used for parallel builds, but we don't want the
  # cmake configure hook to kick in.
  dontUseCmakeConfigure = true;

  # We don't have any tests in this package (yet).
  doCheck = false;

  preBuild = ''
    export MAX_JOBS=$NIX_BUILD_CORES
  '';

  pythonImportsCheck = [ "eetq" ];

  meta = with lib; {
    description = "EETQ";
    license = licenses.asl20;
  };
}
