{
  description = "CV PDF generator";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    typst.url = "github:typst/typst";
  };

  outputs = { nixpkgs, typst, self, ... }@inputs:
    let
      systems = builtins.attrNames nixpkgs.legacyPackages;

      forAllSystems = function: nixpkgs.lib.genAttrs systems
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = builtins.attrValues self.overlays;
              config.allowUnfree = true;
            };
          in
          function pkgs
        );
    in
    {
      packages = forAllSystems (pkgs: import ./packages.nix { inherit pkgs inputs; });
      devShells = forAllSystems (pkgs: {
        default = pkgs.callPackage ./shell.nix { inherit inputs; };
      });
      overlays = import ./overlays.nix { inherit inputs; };
    };
}
