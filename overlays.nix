{ inputs }:

let
  typst = final: pref: {
    typst = inputs.typst.packages.${final.stdenv.system}.default;
  };

in {
  inherit typst;
  default = typst;
}
