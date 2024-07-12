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

  parseArgs = name: ''
    function usage {
      echo "Usage: ${name} [--template <path>] path/to/input.json [path/to/output.json]"
      echo ""
      echo "Options:"
      echo "  -t, --template        Specify which template folder to use. Useful when working on the template itself"
    }

    INPUT_JSON=
    OUTPUT_PDF=
    TEMPLATE="${template}"

    while [[ "$#" -gt 0 ]]; do
      i="$1"; shift
      case "$i" in
        -t|--template)
          TEMPLATE="$1"; shift
          ;;
        -*)
          echo "Error: Unknown argument $1" >> /dev/stderr
          usage
          exit 1
          ;;
        *)
          if [[ -z "$INPUT_JSON" ]]; then
            INPUT_JSON="$(realpath "$i")"
          elif [[ -z "$OUTPUT_PDF" ]]; then
            OUTPUT_PDF="$(realpath "$i")"
          else
            echo "Error: Unknown argument $1" >> /dev/stderr
            usage
            exit 1
          fi
          ;;
      esac
    done

    if [[ -z "$INPUT_JSON" ]]; then
      echo "Error: Missing argument path/to/input.json"
      usage
      exit 1
    fi

    if [[ -z "$OUTPUT_PDF" ]]; then
      OUTPUT_PDF="$(pwd)/cv.pdf"
    fi
  '';

  compile = pkgs.writeShellApplication rec {
    name = "cvgen-compile";
    runtimeInputs = with pkgs; [
      typst
    ];
    text = ''
      ${parseArgs name}

      typst compile \
        --root / \
        --font-path ${pkgs.liberation_ttf}/share/fonts/opentype \
        --font-path ${pkgs.font-awesome_6}/share/fonts/opentype \
        --input INPUT_JSON="$INPUT_JSON" \
        --input THEME=${lib.escapeShellArg "${palette}/palette.json"} \
        "$TEMPLATE/template.typ" \
        "$OUTPUT_PDF"
    '';
  };


  watch = pkgs.writeShellApplication rec {
    name = "cvgen-watch";
    runtimeInputs = with pkgs; [
      typst
      inotifyTools
    ];
    text = ''
      ${parseArgs name}

      ARGS=("--template" "$TEMPLATE" "$INPUT_JSON" "$OUTPUT_PDF")

      function compile {
        if ${lib.getExe compile} "''${ARGS[@]}"; then
          echo "Updated successfully"
        fi
      }

      compile

      readarray -t TRANSITIVE_REFERENCES < <(${lib.getExe transitiveReferences} "$INPUT_JSON")

      while inotifywait --quiet --quiet --recursive --event close_write "''${TRANSITIVE_REFERENCES[@]}" "$TEMPLATE"
      do
        clear
        compile

        readarray -t TRANSITIVE_REFERENCES < <(${lib.getExe transitiveReferences} "$INPUT_JSON")
      done

    '';
  };
in

{
  inherit compile watch;
  default = compile;
}
