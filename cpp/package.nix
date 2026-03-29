{
  self,
  stdenv,
  cmake,
}:
let
  commit = self.shortRev or self.dirtyShortRev or "dirty";
in
stdenv.mkDerivation {
  pname = "app";
  version = "0.1.0+${commit}";
  src = ./.;

  nativeBuildInputs = [ cmake ];

  installPhase = ''
    install -Dm755 app $out/bin/app
  '';

  meta.mainProgram = "app";
}
