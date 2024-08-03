{
  description = "tgi development";

  inputs.nixpkgs.url = github:danieldk/nixpkgs/cudnn-9.3;

  outputs = { self, nixpkgs }:
    with import nixpkgs;
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (system:
        with import nixpkgs { inherit system; config = { allowUnfree = true; }; };
        callPackage ./default.nix { }
      );

      devShells = forAllSystems (system:
        with import nixpkgs { inherit system; config = { allowUnfree = true; }; }; {
          default = mkShell {
            buildInputs = [
              (python3.withPackages (ps: with self.packages.${system}.python3Packages; [
                marlin-kernels
                torch-bin
              ]))
            ];
          };
        }
      );
    };
}
