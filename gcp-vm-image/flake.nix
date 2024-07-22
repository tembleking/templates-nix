{
  description = "NixOS configuration for GCP VM Image creation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-generators,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    generateFor = format:
      nixos-generators.nixosGenerate {
        inherit system format;
        specialArgs = inputs;
        modules = [
          ./configuration.nix
        ];
      };
  in {
    packages.${system} = rec {
      gce = generateFor "gce";
      default = gce;
    };

    formatter = pkgs.alejandra;
  };
}
