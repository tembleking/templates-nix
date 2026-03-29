{ buildGoModule }:
buildGoModule {
  pname = "app";
  version = "0.1.0";
  src = ./.;
  vendorHash = null;

  subPackages = [ "cmd/app" ];

  ldflags = [
    "-w"
    "-s"
  ];

  env.CGO_ENABLED = 0;

  meta.mainProgram = "app";
}
