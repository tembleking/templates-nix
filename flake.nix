{
  description = "A collection of flake templates";

  outputs = { self }: {

    templates = {

      devenv = {
        path = ./devenv;
        description = "A very basic flake for development";
      };

      python-poetry = {
        path = ./python-poetry;
        description = "A basic template for Python applications managed with poetry";
      };

    };

    defaultTemplate = self.templates.devenv;

  };
}
