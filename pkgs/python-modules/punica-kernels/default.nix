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
  torch,
}:

buildPythonPackage rec {
  pname = "punica-kernels";
  version = "1.1.0-dev";

  src = fetchFromGitHub {
    owner = "predibase";
    repo = "lorax";
    rev = "c71861a653412267dc27ec86013dd945ce3474bc";
    fetchSubmodules = true;
    hash = "sha256-FzMifkv94SJP5wVcoGja3OAF6REoJB/RBhrBKcDXa/0=";
  };

  patches = [
    ./fix-asm-output-operand-modifiers.diff
    ./include-cstdint.diff
  ];

  stdenv = cudaPackages.backendStdenv;

  sourceRoot = "${src.name}/server/punica_kernels";

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

  env =
    let
      # Only supports compute capability 8.0 or later.
      cudaCapabilities = lib.filter (v: lib.versionAtLeast v "8.0") torch.cudaCapabilities;
    in
    {
      CUDA_HOME = lib.getDev cudaPackages.cuda_nvcc;
      TORCH_CUDA_ARCH_LIST = lib.concatStringsSep ";" cudaCapabilities;
    };

  propagatedBuildInputs = [ torch ];

  # cmake/ninja are used for parallel builds, but we don't want the
  # cmake configure hook to kick in.
  dontUseCmakeConfigure = true;

  preBuild = ''
    export MAX_JOBS=$NIX_BUILD_CORES
  '';

  # We don't have any tests in this package (yet).
  doCheck = false;

  pythonImportsCheck = [ "punica_kernels" ];

  meta = with lib; {
    description = "Serving multiple LoRA finetuned LLM as one";
    license = licenses.asl20;
  };
}
