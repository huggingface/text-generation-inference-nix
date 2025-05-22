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
  pname = "flashinfer";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "flashinfer-ai";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-NxcctI4mnqbLcat5y2UgV6Y2QdddVQS1KPjh9EHaRek=";
  };

  prePatch = "chmod -R +w ..";

  stdenv = cudaPackages.backendStdenv;

  buildInputs = with cudaPackages; [
    torch.cxxdev
  ];

  nativeBuildInputs = [
    autoAddDriverRunpath
    cmake
    ninja
    cudaPackages.cuda_nvcc
    which
  ];

  dependencies = [ torch ];

  env = {
    TORCH_CUDA_ARCH_LIST = lib.concatStringsSep ";" torch.cudaCapabilities;
    FLASHINFER_ENABLE_AOT = 1;
  };

  depends = [ torch ];

  # cmake/ninja are used for parallel builds, but we don't want the
  # cmake configure hook to kick in.
  dontUseCmakeConfigure = true;

  # We don't have any tests in this package (yet).
  doCheck = false;

  preBuild = ''
    export MAX_JOBS=$NIX_BUILD_CORES
  '';

  postBuild = ''
    export HOME=$(mktemp -d)
  '';

  pythonImportsCheck = [ "flashinfer" ];

  meta = with lib; {
    description = "Flashinfer";
    license = licenses.asl20;
  };
}
