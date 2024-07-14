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
      if [[ "$#" -lt 1 ]]; then
        echo "Usage: ${name} path/to/input.json"
        exit 1
      fi

      INPUT_JSON="$1"; shift
      echo "$INPUT_JSON"

      PHOTO=$(jq --raw-output '.photo' < "$INPUT_JSON")
      if [[ -n "$PHOTO" ]]; then
        echo "$PHOTO"
      fi
    '';
  };

  cvgen = pkgs.writeShellApplication rec {
    name = "cvgen";
    runtimeInputs = with pkgs; [
      typst
      inotifyTools
    ];
    text = ''
      function usage {
        echo "Usage:"
        echo "  ${name} [<option>] ..."
        echo ""
        echo "OPTIONS"
        echo "  -f, --file <path>         JSON file to use as input"
        echo "  -j, --json <json>         JSON to use as input. Overrides definitions given via --file option"
        echo "  -h, --help                Show this list of command-line options"
        echo "  -o, --output <path>       Specify the output path for the generated PDF."
        echo "  -t, --template <path>     Specify which template folder to use. Useful when working on the template itself"
        echo "  -w, --watch               Continuously watch inputs and template for changes and regenerate PDF"
      }

      JSON_FILE=
      JSON=
      OUTPUT="$(pwd)/cv.pdf"
      TEMPLATE="${template}"
      WATCH=

      while [[ "$#" -gt 0 ]]; do
        i="$1"; shift
        case "$i" in
          -h|--help)
            usage
            exit 0
            ;;
          -f|--file)
            JSON_FILE="$(realpath "$1")"; shift
            ;;
          -j|--json)
            JSON="$1"; shift
            ;;
          -o|--output)
            OUTPUT="$(realpath "$1")"; shift
            ;;
          -t|--template)
            TEMPLATE="$1"; shift
            ;;
          -w|--watch)
            WATCH="true"
            ;;
          *)
            echo "Error: Unknown argument $i" >> /dev/stderr
            usage
            exit 1
            ;;
        esac
      done

      function compile {
        typst compile \
          --root / \
          --font-path ${pkgs.liberation_ttf}/share/fonts/opentype \
          --font-path ${pkgs.font-awesome_6}/share/fonts/opentype \
          --input JSON="$JSON" \
          --input JSON_FILE="$JSON_FILE" \
          --input THEME=${lib.escapeShellArg "${palette}/palette.json"} \
          "$TEMPLATE/template.typ" \
          "$OUTPUT"
      }

      filter_existing() {
        while [[ "$#" -gt 0 ]]; do
          item="$1"; shift
          if [[ -e "$item" ]]; then
            echo "$item"
          fi
        done
      }

      function fetch_references {
        TRANSITIVE_REFERENCES=()
        if [[ -n "$JSON_FILE" ]]; then
          readarray -t TRANSITIVE_REFERENCES < <(${lib.getExe transitiveReferences} "$JSON_FILE")
          readarray -t TRANSITIVE_REFERENCES < <(filter_existing "''${TRANSITIVE_REFERENCES[@]}")
        fi
      }

      if [[ -z "$WATCH" ]]; then
        compile
      else
        do=true
        while $do || inotifywait --quiet --quiet --recursive --event close_write "''${TRANSITIVE_REFERENCES[@]}" "$TEMPLATE"; do
          do=false

          clear
          if compile; then
            echo "Updated successfully"
          fi
          fetch_references
        done
      fi
    '';
  };
in

{
  inherit cvgen;
  default = cvgen;
}
