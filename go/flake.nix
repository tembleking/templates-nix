{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    go-overlay.url = "github:purpleclay/go-overlay";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      go-overlay,
    }:
    let
      overlays.default = final: prev: {
        app = prev.callPackage ./package.nix { };
      };
      flake = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              self.overlays.default
              go-overlay.overlays.default
            ];
          };
        in
        {
          packages = with pkgs; {
            inherit app;
            default = app;
          };
          devShells.default =
            with pkgs;
            mkShell {
              packages = [
                go-bin.latestStable
                golangci-lint
                gopls
                govulncheck
              ];
            };

          formatter = pkgs.nixfmt-tree;
        }
      );
    in
    flake // { inherit overlays; };
}
