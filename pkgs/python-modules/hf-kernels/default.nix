{
  buildPythonPackage,
  fetchPypi,
  setuptools,
  huggingface-hub,
  torch,
}:

buildPythonPackage rec {
  pname = "hf-kernels";
  version = "0.1.6";

  src = fetchPypi {
    pname = "hf_kernels";
    inherit version;
    hash = "sha256-Xv/uUEZVLOIm/4bThwp5n07K45m8sr60BGwowt1zbS8=";
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
