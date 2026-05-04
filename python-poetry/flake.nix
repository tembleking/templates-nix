{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    poetry2nix-python.url = "github:nix-community/poetry2nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      poetry2nix-python,
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

        poetryApp = pkgs.callPackage ./package.nix {
          inherit (pkgs) poetry2nix;
        };
      in
      {
        packages = {
          default = poetryApp.package;
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = [
            (pkgs.poetry2nix.mkPoetryEnv {
              projectDir = self;
              inherit (poetryApp) overrides;
            })
            pkgs.poetry
          ];
        };

        formatter = pkgs.nixfmt-tree;
      }
    );
}
