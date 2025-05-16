{
  rustPlatform,
  fetchCrate,
}:

rustPlatform.buildRustPackage rec {
  pname = "build2cmake";
  version = "0.2.1";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-ksoFcjVJIPplQIgbYILMvfuozdhHj6SL5tBhVl4zKVk=";
  };

  cargoHash = "sha256-Ip+XvzTtWN9aXyOrvyCuHZe1QZlrqsL/A92ascu6Jfg=";

  meta = {
    description = "Converts build.toml to CMake";
  };
}
