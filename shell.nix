{ pkgs, lib, inputs, ... }:

let
  system = pkgs.stdenv.system;
  cvgen = inputs.self.packages.${system}.cvgen;

  update-docs = pkgs.writeShellApplication {
    name = "update-docs";
    runtimeInputs = [
      cvgen
      pkgs.imagemagickBig
    ];
    text = ''
      DOCS_CV_JSON="$FLAKE_ROOT/docs/cv.json"
      DOCS_CV_PDF="$FLAKE_ROOT/docs/cv.pdf"
      DOCS_CV_PNG="$FLAKE_ROOT/docs/cv.png"

      cvgen compile "$DOCS_CV_JSON" "$DOCS_CV_PDF"
      magick -density 300 "$DOCS_CV_PDF" "$DOCS_CV_PNG"
    '';
  };

  cvgen-dev = pkgs.writeShellApplication {
    name = "cvgen-dev";
    runtimeInputs = [ cvgen ];
    text = ''
      cvgen watch --template "$FLAKE_ROOT/template" "$@"
    '';
  };
in
pkgs.mkShell {
  packages = [
    pkgs.typst
    pkgs.nixd
    pkgs.nixpkgs-fmt
    update-docs
    cvgen-dev
  ];
  shellHook = ''
    export FLAKE_ROOT="$(git rev-parse --show-toplevel)"
  '';
}
