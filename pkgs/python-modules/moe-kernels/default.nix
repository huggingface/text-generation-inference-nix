{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  autoAddDriverRunpath,
  cmake,
  ninja,
  which,
  cudaPackages,
  nvidia-ml-py,
  torch,
}:

buildPythonPackage rec {
  pname = "moe-kernels";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "danieldk";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-KGV8IAvLIO5ArcdISmRtwyqGzq/LLadeAYW4W5qBOoo=";
  };

  stdenv = cudaPackages.backendStdenv;

  buildInputs = with cudaPackages; [
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

  env = {
    CUDA_HOME = "${lib.getDev cudaPackages.cuda_nvcc}";
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

  pythonImportsCheck = [ "moe_kernels" ];

  meta = with lib; {
    description = "Mixture of Experts kernels";
    license = licenses.asl20;
  };
}
