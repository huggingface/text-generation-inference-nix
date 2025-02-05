{
  buildPythonPackage,
  fetchPypi,
  setuptools,
  huggingface-hub,
  torch,
}:

buildPythonPackage rec {
  pname = "hf-kernels";
  version = "0.1.5";

  src = fetchPypi {
    pname = "hf_kernels";
    inherit version;
    hash = "sha256-fe5UfMCP8+Wz1Lb+wx1EcGNkZbynYa/LE3i1jNHv4YA=";
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
