{
  accelerate,
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
  transformers,
}:

buildPythonPackage rec {
  pname = "EETQ";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "NetEase-FuXi";
    repo = pname;
    rev = "465e9726bf7ae30803a2d0dd9e5d4315aef17491";
    fetchSubmodules = true;
    hash = "sha256-VsK3jYmxiQsDyYTMDI7hntm7e9BGKIJqvuq0WairqhE=";
  };

  stdenv = cudaPackages.backendStdenv;

  buildInputs = with cudaPackages; [
    cuda_nvtx
    cuda_cccl
    cuda_cudart
    libcublas
    libcusolver
    libcusparse
  ];

  nativeBuildInputs = [
    autoAddDriverRunpath
    cmake
    ninja
    which
  ];

  dependencies = [
    accelerate
    psutil
    torch
    transformers
  ];

  env = {
    CUDA_HOME = lib.getDev cudaPackages.cuda_nvcc;
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
    description = "Easy and Efficient Quantization for Transformers";
    license = licenses.asl20;
  };
}
