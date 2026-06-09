{
  description = "A collection of flake templates";

  outputs =
    { self }:
    {
      templates = {
        base = {
          path = ./base;
          description = "A very basic flake for development";
        };

        devenv = {
          path = ./devenv;
          description = "A basic flake for development using devenv";
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

        rust = {
          path = ./rust;
          description = "Rust application";
        };

        go = {
          path = ./go;
          description = "Go application";
        };

        cpp = {
          path = ./cpp;
          description = "C++ application with CMake";
        };
      };

      defaultTemplate = self.templates.base;
    };
}
