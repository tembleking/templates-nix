{
  description = "NixOS configuration for AWS EC2 AMI creation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      # Systems the AMI can be built for (x86_64 and Graviton instances).
      imageSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      # Systems the formatter is available on.
      allSystems = imageSystems ++ [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forSystems = systems: f: nixpkgs.lib.genAttrs systems f;

      mkSystem =
        system:
        nixpkgs.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            { nixpkgs.hostPlatform = system; }
            ./configuration.nix
          ];
        };
    in
    {
      nixosConfigurations = forSystems imageSystems mkSystem;

      packages = forSystems imageSystems (system: rec {
        amazon = self.nixosConfigurations.${system}.config.system.build.images.amazon;
        default = amazon;
      });

      formatter = forSystems allSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
