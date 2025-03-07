{
  buildPythonPackage,
  fetchPypi,
  setuptools,
  huggingface-hub,
  torch,
}:

buildPythonPackage rec {
  pname = "kernels";
  version = "0.1.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-C1+Q3YNMmpF04pB9tYyWCDjHxtyPqQXvhKlu4/NSiM4=";
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
