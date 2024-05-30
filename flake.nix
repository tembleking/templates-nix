{
  description = "A collection of flake templates";

  outputs = { self }: {

    templates = {

      devenv = {
        path = ./devenv;
        description = "A very basic flake for development";
      };

    };

    defaultTemplate = self.templates.devenv;

  };
}
