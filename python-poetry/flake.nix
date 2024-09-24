{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    poetry2nix-python.url = "github:nix-community/poetry2nix";
    bundlers.url = "github:NixOS/bundlers";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      poetry2nix-python,
      bundlers,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ poetry2nix-python.overlays.default ];
        };

        # Fix from https://github.com/nix-community/poetry2nix/blob/8ffbc64abe7f432882cb5d96941c39103622ae5e/docs/edgecases.md#modulenotfounderror-no-module-named-packagename
        pypkgs-build-requirements = {
          # <- Setup here the package name with the required dependency in case of ModuleNotFoundError
          mamba = [ "setuptools" ];
          doublex = [ "setuptools" ];
          doublex-expects = [ "setuptools" ];
        };
        p2n-overrides = pkgs.poetry2nix.defaultPoetryOverrides.extend (
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

        drv = pkgs.poetry2nix.mkPoetryApplication {
          projectDir = self;
          overrides = p2n-overrides;
          meta.mainProgram = "your-binary-name-here"; # <- Modify your binary name
        };
      in
      {
        packages = {
          default = drv;
          deb = bundlers.bundlers.${system}.toDEB drv; # command: nix build .#deb
          rpm = bundlers.bundlers.${system}.toRPM drv; # command: nix build .#rpm
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = [
            (pkgs.poetry2nix.mkPoetryEnv {
              projectDir = self;
              overrides = p2n-overrides;
            })
            pkgs.poetry
          ];
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
