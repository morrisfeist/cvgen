{
  description = "CV PDF generator";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    typst.url = "github:typst/typst";
  };

  outputs = { nixpkgs, typst, ... }:
    let
      systems = builtins.attrNames nixpkgs.legacyPackages;

      forAllSystems = function: nixpkgs.lib.genAttrs systems
        (system:
          let
            typstOverlay = (final: prev: {
              typst = typst.packages.${system}.default;
            });
            overlays = [ typstOverlay ];
            pkgs = import nixpkgs {
              inherit system overlays;
              config.allowUnfree = true;
            };
          in
          function pkgs
        );
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.typst
            pkgs.nix
            pkgs.nixd
            pkgs.nixpkgs-fmt
          ];
        };
      });
    };
}
