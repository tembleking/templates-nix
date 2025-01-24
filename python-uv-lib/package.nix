{
  buildPythonPackage,
  setuptools,
  setuptools-scm,
}:
buildPythonPackage {
  pname = "my_lib";
  version = "0.1.0";
  src = ./.;
  pyproject = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    # your dependencies
  ];

  pythonImportsCheck = [ "my_lib" ];
}
