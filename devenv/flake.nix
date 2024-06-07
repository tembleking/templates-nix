{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
        with pkgs; {
          devShells.default = mkShell {
            buildInputs = [
              # Add here dependencies for the project.
            ];
          };

          formatter = alejandra;
        }
    );
}
