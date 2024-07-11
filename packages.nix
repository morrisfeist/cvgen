{ pkgs, inputs, ... }:

let
  lib = pkgs.lib;

  palette = builtins.path {
    name = "catpuccin-palette-json";
    path = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "palette";
      rev = "7f17f46c5d3d86f4c8d17fef07d97459744e1157";
      hash = "sha256-3hX7MDaBPyFPTSoHlke0q1geNEdrOzlrIo9CMe2XUB0=";
    };
    filter = path: type: type == "regular" && baseNameOf path == "palette.json";
  };

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

      INPUT_JSON="$(realpath "$1")"; shift

      if [ "$#" -lt 1 ]; then
        OUTPUT_PDF="$(pwd)/cv.pdf"
      else
        OUTPUT_PDF="$1"; shift
      fi

      typst compile \
        --root / \
        --font-path ${pkgs.aileron}/share/fonts/opentype \
        --font-path ${pkgs.font-awesome_6}/share/fonts/opentype \
        --input INPUT_JSON="$INPUT_JSON" \
        --input THEME=${lib.escapeShellArg "${palette}/palette.json"} \
        --input FLAVOR=latte \
        --input ACCENT=sky \
        "${template}/template.typ" \
        "$OUTPUT_PDF"
    '';
  };
in

{
  inherit compile;
  default = compile;
}
