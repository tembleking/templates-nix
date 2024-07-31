{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    poetry2nix-python.url = "github:nix-community/poetry2nix";
    nix-bundle.url = "github:NixOS/bundlers";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    poetry2nix-python,
    nix-bundle,
    utils,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [poetry2nix-python.overlays.default];
        };

        pythonVersion = pkgs.python3; # <- Your python version here, in case you want a different one. For example, one of: python3, python310, python311, python312, etc

        # Fix from https://github.com/nix-community/poetry2nix/blob/8ffbc64abe7f432882cb5d96941c39103622ae5e/docs/edgecases.md#modulenotfounderror-no-module-named-packagename
        pypkgs-build-requirements = {
          # <- Setup here the package name with the required dependency in case of ModuleNotFoundError
          mamba = ["setuptools"];
          doublex = ["setuptools"];
          doublex-expects = ["setuptools"];
        };
        p2n-overrides = pkgs.poetry2nix.defaultPoetryOverrides.extend (
          self: super:
            builtins.mapAttrs (
              package: build-requirements:
                (builtins.getAttr package super).overridePythonAttrs (old: {
                  buildInputs =
                    (old.buildInputs or [])
                    ++ (builtins.map (pkg:
                      if builtins.isString pkg
                      then builtins.getAttr pkg super
                      else pkg)
                    build-requirements);
                })
            )
            pypkgs-build-requirements
        );

        drv = pkgs.poetry2nix.mkPoetryApplication {
          projectDir = self;
          python = pythonVersion;
          overrides = p2n-overrides;
          meta.mainProgram = "your-binary-name-here"; # <- Modify your binary name
        };
      in {
        packages = {
          default = drv;
          deb = nix-bundle.bundlers.${system}.toDEB drv; # command: nix build .#deb
          rpm = nix-bundle.bundlers.${system}.toRPM drv; # command: nix build .#rpm
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = [
            (pkgs.poetry2nix.mkPoetryEnv {
              projectDir = self;
              python = pythonVersion;
              overrides = p2n-overrides;
            })
            pkgs.poetry
          ];
        };

        formatter = pkgs.alejandra;
      }
    );
}
