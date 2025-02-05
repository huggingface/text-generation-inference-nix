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
    rev = "eabeadcedba5dcef2a562b8f1ed5ec1feb485496";
    hash = "sha256-QPWRaIPAMmQANuAOaZIKzh1e69OG8zBWGg+swESEajw=";
  };

  sourceRoot = "${src.name}/toml2cmake";

  cargoHash = "sha256-QzzuoTu9nb16GU93GBdA/Nybtt/T31MysCOPWuD8e2w=";

  meta = {
    description = "Converts build.toml to CMake";
  };
}
