{ pkgs, ... }:

let
  template = builtins.path {
    name = "cvgen-template";
    path = ./template;
  };

  compile = pkgs.writeShellApplication {
    name = "cvgen-compile";
    runtimeInputs = with pkgs; [
      typst
    ];
    text = ''
      if [ "$#" -lt 1 ]; then
        echo "Usage: cvgen-compile path/to/input.json [path/to/output.pdf]"
        exit 1
      fi

      INPUT_JSON="$1"; shift

      if [ "$#" -lt 1 ]; then
        OUTPUT_PDF="$(pwd)/cv.pdf"
      else
        OUTPUT_PDF="$1"; shift
      fi

      typst compile \
        --root / \
        --input INPUT_JSON="$INPUT_JSON" \
        "${template}/main.typ" \
        "$OUTPUT_PDF"
    '';
  };
in

{
  inherit compile;
  default = compile;
}
