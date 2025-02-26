{
  buildPythonPackage,
  setuptools,
  setuptools-scm,
}:
let
  pyproject = builtins.fromTOML (builtins.readFile ./pyproject.toml);
in
buildPythonPackage {
  pname = pyproject.project.name;
  version = pyproject.project.version;
  src = ./.;
  pyproject = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    # your dependencies
  ];

  pythonImportsCheck = [ pyproject.project.name ];
}
