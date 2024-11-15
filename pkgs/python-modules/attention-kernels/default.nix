{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  autoAddDriverRunpath,
  cmake,
  ninja,
  packaging,
  setuptools,
  wheel,
  which,
  cudaPackages,
  nvidia-ml-py,
  torch,
}:

buildPythonPackage rec {
  pname = "attention-kernels";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "danieldk";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-yycP99wyQmOlJlwCL4Dk8gb2ZP0BGDr6H8fuPdVxNr0=";
  };

  stdenv = cudaPackages.backendStdenv;

  nativeBuildInputs = with cudaPackages; [
    autoAddDriverRunpath
    cmake
    cuda_nvcc
    ninja
    which
  ];

  build-system = [
    packaging
    setuptools
    wheel
  ];

  buildInputs = with cudaPackages; [
    cuda_cccl
    cuda_cudart
    cuda_nvtx
    libcublas
    libcusolver
    libcusparse
  ];

  env = {
    CUDA_HOME = "${lib.getDev cudaPackages.cuda_nvcc}";
    TORCH_CUDA_ARCH_LIST = lib.concatStringsSep ";" torch.cudaCapabilities;
  };

  dependencies = [
    nvidia-ml-py
    torch
  ];

  # cmake/ninja are used for parallel builds, but we don't want the
  # cmake configure hook to kick in.
  dontUseCmakeConfigure = true;

  # We don't have any tests in this package (yet).
  doCheck = false;

  pythonImportsCheck = [ "attention_kernels" ];

  meta = with lib; {
    description = "Attention kernels";
    license = licenses.asl20;
  };
}
