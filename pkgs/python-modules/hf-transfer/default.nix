{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  rustPlatform,
  perl,
  openssl,
}:

buildPythonPackage rec {
  pname = "hf-transfer";
  version = "0.1.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "hf_transfer";
    rev = "v${version}";
    hash = "sha256-Uh8q14OeN0fYsywYyNrH8C3wq/qRjQKEAIufi/a5RXA=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-I4APdz1r2KJ8pTfKAg8g240wYy8gtMlHwmBye4796Tk=";
  };

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeBuildInputs = [
    # Used by the build script of the openssl crate.
    perl
  ];

  buildInputs = [ openssl.dev ];

  meta = with lib; {
    description = "Speed up file transfers with Hugging Face Hub";
    license = licenses.asl20;
  };
}
