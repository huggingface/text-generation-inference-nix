{
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "toml2cmake";
  version = "dev";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "kernel-builder";
    rev = "60702d5c9e18b0939a76b8eb811d856af1a731cc";
    hash = "sha256-N9oRAPg2Pyi38cYEgCSqO7SAT1DU5SdeMoRve5aFNXc=";
  };

  sourceRoot = "${src.name}/toml2cmake";

  cargoHash = "sha256-QzzuoTu9nb16GU93GBdA/Nybtt/T31MysCOPWuD8e2w=";

  meta = {
    description = "Converts build.toml to CMake";
  };
}
