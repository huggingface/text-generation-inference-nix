{
  buildPythonPackage,
  fetchPypi,
  setuptools,
  huggingface-hub,
  torch,
}:

buildPythonPackage rec {
  pname = "hf-kernels";
  version = "0.1.4";

  src = fetchPypi {
    pname = "hf_kernels";
    inherit version;
    hash = "sha256-/BzBZmKD0NPxX8/BgCaluZDxBr180D9ARo0GSHAkb7o=";
  };

  pyproject = true;

  build-system = [ setuptools ];

  dependencies = [
    huggingface-hub
    torch
  ];

  pythonImportsCheck = [ "hf_kernels" ];

  meta = {
    description = "Fetch compute kernels from the hub";
  };
}
