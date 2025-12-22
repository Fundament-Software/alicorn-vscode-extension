{
  description =
    "vscode extension for the Alicorn language";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs
    , flake-utils
    , pre-commit-hooks
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      perSystem = {
        packages = {
          alicorn-vscode-extension = pkgs.callPackage ./alicorn-vscode-extension.nix { };
          default = perSystem.packages.alicorn-vscode-extension;
        };
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              statix.enable = true;
              nixpkgs-fmt.enable = true;
              deadnix.enable = true;
            };
          };
        } // perSystem.packages;
        formatter = pkgs.writeShellApplication {
          name = "run-formatters";
          runtimeInputs = [ pkgs.nixpkgs-fmt ];
          text = ''
            set -xeu
            nixpkgs-fmt "$@"
          '';
        };
        devShells = {
          alicorn-vscode-extension = pkgs.mkShell {
            buildInputs = [
              pkgs.vsce
              pkgs.nixpkgs-fmt
            ];
            inherit (perSystem.checks.pre-commit-check) shellHook;
          };
          default = perSystem.devShells.alicorn-vscode-extension;
        };
      };
    in
    perSystem
    );
}
