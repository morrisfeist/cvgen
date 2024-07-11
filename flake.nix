{
  description = "CV PDF generator";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }@inputs:
    let
      systems = builtins.attrNames nixpkgs.legacyPackages;

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
        let pkgs = import nixpkgs { inherit system; };
        in f pkgs
      );
    in
    {
      packages = forAllSystems (pkgs: import ./packages.nix { inherit pkgs inputs; });
      devShells = forAllSystems (pkgs: {
        default = pkgs.callPackage ./shell.nix { inherit inputs; };
      });
    };
}
