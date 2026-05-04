{
  poetry2nix,
  pypkgs-build-requirements ? {
    # Fix ModuleNotFoundError: map package name to missing build deps
    # https://github.com/nix-community/poetry2nix/blob/8ffbc64abe7f432882cb5d96941c39103622ae5e/docs/edgecases.md#modulenotfounderror-no-module-named-packagename
    # Example:
    # mamba = [ "setuptools" ];
    # uvloop = [ "cython" "setuptools" ];
    # pillow = [ "setuptools" ];
  },
}:
let
  overrides = poetry2nix.defaultPoetryOverrides.extend (
    self: super:
    builtins.mapAttrs (
      package: build-requirements:
      (builtins.getAttr package super).overridePythonAttrs (old: {
        buildInputs =
          (old.buildInputs or [ ])
          ++ (builtins.map (
            pkg: if builtins.isString pkg then builtins.getAttr pkg super else pkg
          ) build-requirements);
      })
    ) pypkgs-build-requirements
  );
in
{
  inherit overrides;

  package = poetry2nix.mkPoetryApplication {
    projectDir = ./.;
    inherit overrides;
    meta.mainProgram = "your-binary-name-here"; # <- Modify your binary name
  };
}
