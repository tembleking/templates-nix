{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      devenv,
      flake-utils,
      ...
    }@inputs:
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
          # packages = with pkgs; {
          #   inherit packageName;
          #   default = packageName;
          # };
          devShells.default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              # Full option reference: https://devenv.sh/reference/options/
              (
                { pkgs, ... }:
                {
                  packages = with pkgs; [
                    # Add here dependencies for the project.
                  ];

                  # Environment variables for the shell.
                  # env.GREETING = "Hello";

                  # Enable language toolchains (see https://devenv.sh/languages/).
                  # languages.go.enable = true;
                  # languages.rust.enable = true;
                  # languages.python = {
                  #   enable = true;
                  #   uv.enable = true;
                  # };

                  # Project scripts, available as commands in the shell.
                  # scripts.hello.exec = "echo hello from $GREETING";

                  # Tasks with dependencies via before/after (https://devenv.sh/tasks/).
                  # tasks = {
                  #   "myapp:setup".exec = "echo setting up";
                  #   "myapp:build" = {
                  #     exec = "echo building";
                  #     after = [ "myapp:setup" ];
                  #     before = [ "myapp:test" ];
                  #   };
                  #   "myapp:test".exec = "echo testing";
                  # };

                  # Runs on `direnv` reload / `devenv shell`.
                  # enterShell = ''
                  #   echo "welcome to the dev shell"
                  # '';

                  # Tests to verify the dev environment is set up correctly,
                  # run with `devenv test` (https://devenv.sh/tests/).
                  # enterTest = ''
                  #   echo "checking the dev environment"
                  #   git --version | grep --color=auto "git version"
                  # '';

                  # Pre-commit / git hooks (https://devenv.sh/git-hooks/).
                  # git-hooks.hooks = {
                  #   nixfmt-rfc-style.enable = true;
                  #   shellcheck.enable = true;
                  # };

                  # Long-running processes started with `devenv up`.
                  # processes.server.exec = "python -m http.server";

                  # Services like postgres, redis, etc (https://devenv.sh/services/).
                  # services.postgres.enable = true;
                }
              )
            ];
          };

          formatter = pkgs.nixfmt-tree;
        }
      );
    in
    flake // { inherit overlays; };
}
