{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      overlays.default = final: prev: {
        app = prev.callPackage ./package.nix { inherit self; };
      };
      flake = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ self.overlays.default ];
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
                clang-tools
              ];
              inputsFrom = [ app ];
              shellHook = ''
                cmake -S . -G "Unix Makefiles" -B build
              '';
            };

          formatter = pkgs.nixfmt-tree;
        }
      );
    in
    flake // { inherit overlays; };
}
