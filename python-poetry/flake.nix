{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    poetry2nix.url = "github:nix-community/poetry2nix";
    nix-bundle.url = "github:NixOS/bundlers";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    poetry2nix,
    nix-bundle,
    utils,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonVersion = pkgs.python3; # <- Your python version here, in case you want a different one. For example, one of: python3, python310, python311, python312, etc
        inherit (poetry2nix.lib.mkPoetry2Nix {pkgs = pkgs;}) mkPoetryApplication defaultPoetryOverrides mkPoetryEnv;

        # Fix from https://github.com/nix-community/poetry2nix/blob/8ffbc64abe7f432882cb5d96941c39103622ae5e/docs/edgecases.md#modulenotfounderror-no-module-named-packagename
        pypkgs-build-requirements = {
          # <- Setup here the package name with the required dependency in case of ModuleNotFoundError
          mamba = ["setuptools"];
          doublex = ["setuptools"];
          doublex-expects = ["setuptools"];
        };
        p2n-overrides = defaultPoetryOverrides.extend (
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

        drv = mkPoetryApplication {
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

        devShells = {
          default = pkgs.mkShellNoCC {
            packages = [
              (mkPoetryEnv {
                projectDir = self;
                python = pythonVersion;
                overrides = p2n-overrides;
              })
              pkgs.poetry
            ];
          };
        };

        formatter = pkgs.alejandra;
      }
    );
}
