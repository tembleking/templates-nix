{
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "app";
  version = "0.1.0";
  src = ./.;
  pyproject = true;

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    # your dependencies
  ];

  meta.mainProgram = "app"; # Your script name to execute as command
}
