{
  description = "NixOS configuration for GCP VM Image creation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    vm-system = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules = [
        "${nixpkgs}/nixos/modules/virtualisation/google-compute-image.nix"
        ./configuration.nix
      ];
    };
  in {
    packages.${system} = rec {
      gcp-vm-image = vm-system.config.system.build.googleComputeImage;
      default = gcp-vm-image;
    };

    formatter = pkgs.alejandra;
  };
}
