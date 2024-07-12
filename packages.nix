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

  transitiveReferences = pkgs.writeShellApplication rec {
    name = "cvgen-transitive-references";
    text = ''
      if [ "$#" -lt 1 ]; then
        echo "Usage: ${name} path/to/input.json"
        exit 1
      fi

      INPUT_JSON="$1"; shift
      echo "$INPUT_JSON"

      PHOTO=$(jq --raw-output '.photo' < "$INPUT_JSON")
      if [ -n "$PHOTO" ]; then
        echo "$PHOTO"
      fi
    '';
  };

  compile = pkgs.writeShellApplication rec {
    name = "cvgen-compile";
    runtimeInputs = with pkgs; [
      typst
    ];
    text = ''
      if [ "$#" -lt 1 ]; then
        echo "Usage: ${name} path/to/input.json [path/to/output.pdf]"
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
        --font-path ${pkgs.liberation_ttf}/share/fonts/opentype \
        --font-path ${pkgs.font-awesome_6}/share/fonts/opentype \
        --input INPUT_JSON="$INPUT_JSON" \
        --input THEME=${lib.escapeShellArg "${palette}/palette.json"} \
        "${template}/template.typ" \
        "$OUTPUT_PDF"
    '';
  };


  watch = pkgs.writeShellApplication
    {
      name = "cvgen-watch";
      runtimeInputs = with pkgs; [
        typst
        inotifyTools
      ];
      text = ''
        if [ "$#" -lt 1 ]; then
          echo "Usage: cvgen-compile path/to/input.json [path/to/output.pdf]"
          exit 1
        fi

        INPUT_JSON="$(realpath "$1")"; shift

        set +e
        ${lib.getExe compile} "$INPUT_JSON" "$@"
        set -e

        readarray -t TRANSITIVE_REFERENCES < <(${lib.getExe transitiveReferences} "$INPUT_JSON")

        while inotifywait --quiet --quiet --event close_write "''${TRANSITIVE_REFERENCES[@]}"
        do
          clear
          set +e
          ${lib.getExe compile} "$INPUT_JSON" "$@"
          set -e

          readarray -t TRANSITIVE_REFERENCES < <(${lib.getExe transitiveReferences} "$INPUT_JSON")
        done

      '';
    };
in

{
  inherit compile watch;
  default = compile;
}
