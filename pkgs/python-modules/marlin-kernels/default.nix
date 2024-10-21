{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  autoAddDriverRunpath,
  cmake,
  ninja,
  which,
  packaging,
  setuptools,
  wheel,
  cudaPackages,
  torch,
}:

let
  cutlass = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "cutlass";
    rev = "refs/tags/v3.5.1";
    hash = "sha256-sTGYN+bjtEqQ7Ootr/wvx3P9f8MCDSSj3qyCWjfdLEA=";
  };
in buildPythonPackage rec {
  pname = "marlin-kernels";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "danieldk";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Fw/pWQChJ/bB3MfRTmUYhklJHVvgS5cMGIOcqHPZed4=";
  };


  patches = [
    ./setup.py-nix-support-respect-cmakeFlags.patch
  ];

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

  propagatedBuildInputs = [ torch ];

  # cmake/ninja are used for parallel builds, but we don't want the
  # cmake configure hook to kick in.
  dontUseCmakeConfigure = true;

  cmakeFlags = [ (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_CUTLASS" "${lib.getDev cutlass}") ];

  # We don't have any tests in this package (yet).
  doCheck = false;

  pythonImportsCheck = [ "marlin_kernels" ];

  meta = with lib; {
    description = "Marlin quantization kernels";
    license = licenses.asl20;
  };
}
