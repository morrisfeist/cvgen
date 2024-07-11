{ pkgs, lib, inputs, ... }:

let
  update-docs = pkgs.writeShellApplication {
    name = "update-docs";
    runtimeInputs = with pkgs; [ imagemagickBig ];
    text = ''
      if [ -z "$FLAKE_ROOT" ]; then
        echo "Error: Environment variable FLAKE_ROOT is not set" >> /dev/stderr
        exit 1
      elif [ ! -d "$FLAKE_ROOT" ]; then
        echo "Error: Environment variable FLAKE_ROOT does not contain the path to a directory" >> /dev/stderr
        exit 1
      fi
      REPO_PATH="$FLAKE_ROOT"

      DOCS_CV_JSON="$REPO_PATH/docs/cv.json"
      DOCS_CV_PDF="$REPO_PATH/docs/cv.pdf"
      DOCS_CV_PNG="$REPO_PATH/docs/cv.png"

      ${lib.getExe inputs.self.packages.${pkgs.stdenv.system}.compile} "$DOCS_CV_JSON" "$DOCS_CV_PDF"
      magick -density 300 "$DOCS_CV_PDF" "$DOCS_CV_PNG"
    '';
  };
in
pkgs.mkShell {
  packages = [
    pkgs.typst
    pkgs.nixd
    pkgs.nixpkgs-fmt
    update-docs
  ];
  shellHook = ''
    export FLAKE_ROOT="$(git rev-parse --show-toplevel)"
  '';
}
