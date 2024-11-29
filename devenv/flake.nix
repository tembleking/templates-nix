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
        # packageName = prev.callPackage ./package.nix {};
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
            inherit packageName;
            default = packageName;
          };
          devShells.default =
            with pkgs;
            mkShell {
              packages = [
                # Add here dependencies for the project.
              ];
            };

          formatter = pkgs.nixfmt-rfc-style;
        }
      );
    in
    flake // { inherit overlays; };
}
