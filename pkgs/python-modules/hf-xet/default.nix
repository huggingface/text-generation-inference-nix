{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  rustPlatform,
  perl,
  openssl,
  pkg-config,
}:

buildPythonPackage rec {
  pname = "hf-xet";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "xet-core";
    rev = "v${version}";
    hash = "sha256-4eM1H17teHr5IqZCnjr12nAxiWfzbeZ9lrhEHIUnzZs=";
  };

  sourceRoot = "${src.name}/hf_xet";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    sourceRoot = "${src.name}/hf_xet";
    hash = "sha256-dZ2RdMNgWkRZqFGy31ax7TSGMhuPeBac6AHBFFQzirk=";
  };

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeBuildInputs = [
    # Used by the build script of the openssl crate.
    perl
    pkg-config
  ];

  buildInputs = [ openssl.dev ];

  meta = with lib; {
    description = "Speed up file transfers with Hugging Face Hub";
    license = licenses.asl20;
  };
}
