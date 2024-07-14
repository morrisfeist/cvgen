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
        echo "  ${name} <command> [<option> ...] <path/to/input.json> [<path/to/output.pdf>]"
        echo ""
        echo "COMMANDS"
        echo "  compile                   Generate PDF file from the given JSON file"
        echo "  watch                     Continuously watch input files for changes and regenerate PDF"
        echo ""
        echo "OPTIONS"
        echo "  -h, --help                Show this list of command-line options"
        echo "  -o, --override <json>     Override values specified in the input.json"
        echo "  -t, --template <path>     Specify which template folder to use. Useful when working on the template itself"
      }

      COMMAND=
      INPUT_JSON=
      OUTPUT_PDF=
      TEMPLATE="${template}"
      OVERRIDE=

      while [[ "$#" -gt 0 ]]; do
        i="$1"; shift
        case "$i" in
          -h|--help)
            usage
            exit 0
            ;;
          -t|--template)
            TEMPLATE="$1"; shift
            ;;
          -o|--override)
            OVERRIDE="$1"; shift
            ;;
          -*)
            echo "Error: Unknown argument $i" >> /dev/stderr
            usage
            exit 1
            ;;
          *)
            if [[ -z "$COMMAND" ]]; then
              case "$i" in
                compile)
                  COMMAND="$i"
                  ;;
                watch)
                  COMMAND="$i"
                  ;;
                *)
                  echo "Error: Unknown command $i" >> /dev/stderr
                  usage
                  exit 1
                  ;;
              esac
            elif [[ -z "$INPUT_JSON" ]]; then
              INPUT_JSON="$(realpath "$i")"
            elif [[ -z "$OUTPUT_PDF" ]]; then
              OUTPUT_PDF="$(realpath "$i")"
            else
              echo "Error: Unknown argument $i" >> /dev/stderr
              usage
              exit 1
            fi
            ;;
        esac
      done

      if [[ -z "$COMMAND" ]]; then
        echo "Error: Missing command"
        usage
        exit 1
      fi

      if [[ -z "$INPUT_JSON" ]]; then
        echo "Error: Missing argument path/to/input.json"
        usage
        exit 1
      fi

      if [[ -z "$OUTPUT_PDF" ]]; then
        OUTPUT_PDF="$(pwd)/cv.pdf"
      fi

      function compile {
        typst compile \
          --root / \
          --font-path ${pkgs.liberation_ttf}/share/fonts/opentype \
          --font-path ${pkgs.font-awesome_6}/share/fonts/opentype \
          --input INPUT_JSON="$INPUT_JSON" \
          --input THEME=${lib.escapeShellArg "${palette}/palette.json"} \
          --input OVERRIDE="$OVERRIDE" \
          "$TEMPLATE/template.typ" \
          "$OUTPUT_PDF"
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
        readarray -t TRANSITIVE_REFERENCES < <(${lib.getExe transitiveReferences} "$INPUT_JSON")
        readarray -t TRANSITIVE_REFERENCES < <(filter_existing "''${TRANSITIVE_REFERENCES[@]}")
      }

      case "$COMMAND" in
        compile)
          compile
          ;;
        watch)
          do=true
          while $do || inotifywait --quiet --quiet --recursive --event close_write "''${TRANSITIVE_REFERENCES[@]}" "$TEMPLATE"; do
            do=false

            clear
            if compile; then
              echo "Updated successfully"
            fi
            fetch_references
          done
      esac
    '';
  };
in

{
  inherit cvgen;
  default = cvgen;
}
