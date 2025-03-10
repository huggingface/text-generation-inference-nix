{
  buildPythonPackage,
  fetchPypi,
  setuptools,
  huggingface-hub,
  torch,
}:

buildPythonPackage rec {
  pname = "kernels";
  version = "0.2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-kYlCMygZsoN3udBwcNrd7P2KXnurV03T3GSiCcpgCLI=";
  };

  pyproject = true;

  build-system = [ setuptools ];

  dependencies = [
    huggingface-hub
    torch
  ];

  pythonImportsCheck = [ "kernels" ];

  meta = {
    description = "Fetch compute kernels from the hub";
  };
}
