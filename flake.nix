{
  description = "A collection of flake templates";

  outputs =
    { self }:
    {
      templates = {
        devenv = {
          path = ./devenv;
          description = "A very basic flake for development";
        };

        python-poetry = {
          path = ./python-poetry;
          description = "A basic template for Python applications managed with poetry";
        };

        gcp-vm-image = {
          path = ./gcp-vm-image;
          description = "NixOS configuration for GCP VM Image creation";
        };

        python-uv-app = {
          path = ./python-uv-app;
          description = "Python UV Application";
        };

        python-uv-lib = {
          path = ./python-uv-lib;
          description = "Python UV Library";
        };
      };

      defaultTemplate = self.templates.devenv;
    };
}
