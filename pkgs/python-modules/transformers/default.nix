{
  buildPythonPackage,
  fetchPypi,
  fetchFromGitHub,
  setuptools,
  regex,
  huggingface-hub,
  numpy,
  safetensors,
  tokenizers
}:

buildPythonPackage rec {
  pname = "transformers";

  ## TODO: prefer using pypi when possible
  # version = "4.48.2";
  # src = fetchPypi {
  #   pname = "transformers";
  #   inherit version;
  #   hash = "sha256-3PtzRz5h8i+zNm/iRx7S5Cd57N1JUnob3xk3V0hV1RY=";
  # };

  version = "latest";
  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "transformers";
    rev = "8d73a38606bc342b370afe1f42718b4828d95aaa";
    hash = "sha256-MxroG6CWqrcmRS+eFt7Ej87TDOInN15aRPBUcaycKTI=";
  };

  build-system = [ setuptools ];

  dependencies = [
    regex
    huggingface-hub
    numpy
    safetensors
    tokenizers
  ];

  meta = {
    description = "Fetch a specific version of the transformers library";
  };
}