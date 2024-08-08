{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  ninja,
  scikit-build,
  setuptools-git-versioning,
  tabulate,
  cudaPackages,
  torch,
}:

buildPythonPackage rec {
  pname = "fbgemm-gpu";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "fbgemm";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-fmeBKTtB75H6flY7jO0LirkhGsqM0MlPvYOaOXtf8m0=";
  };

  sourceRoot = "${src.name}/fbgemm_gpu";

  stdenv = cudaPackages.backendStdenv;

  nativeBuildInputs = [
    cmake
    cudaPackages.cuda_nvcc
    ninja
  ];

  build-system = [
    scikit-build
    setuptools-git-versioning
    tabulate
  ];

  buildInputs = with cudaPackages; [
    cuda_cccl # <nv/target>
    cuda_cudart
    cuda_nvtx
    cuda_nvrtc
    libcublas
    libcusolver
    libcusparse
    libcurand
    nccl
  ];

  dependencies = [ torch ];

  env = with cudaPackages; rec {
    CUDAToolkit_ROOT = "${lib.getDev cuda_nvcc}";
    CMAKE_CUDA_ARCHITECTURES = "8.0;9.0a";
    CUDA_BIN_PATH = CUDAToolkit_ROOT;
  };

  #propagatedBuildInputs = [ torch ];

  setupPyGlobalFlags = [
    "--package_variant genai"
    "-DCMAKE_CUDA_ARCHITECTURES='89;90a'"
    "-DCMAKE_CXX_STANDARD=17"
  ];

  # cmake/ninja are used for parallel builds, but we don't want the
  # cmake configure hook to kick in.
  dontUseCmakeConfigure = true;

  # We don't have any tests in this package (yet).
  doCheck = false;

  pythonImportsCheck = [ "fbgemm_gpu" ];

  meta = with lib; {
    description = "Collection of high-performance GPU operations";
    license = licenses.asl20;
  };
}
