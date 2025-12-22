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
          # Test that the combined extension drv home-manager wants to build will work with the alicorn extension
          home-manager-compat =
            let
              ext = perSystem.packages.alicorn-vscode-extension;
              subDir = "share/vscode/extensions";
              extensionJson = builtins.toJSON (map
                (e: {
                  identifier.id = e.vscodeExtUniqueId;
                  version = e.version or "0.0.0";
                  location = {
                    "$mid" = 1;
                    path = "${e}/${subDir}/${e.vscodeExtUniqueId}";
                    scheme = "file";
                  };
                  relativeLocation = e.vscodeExtUniqueId;
                  metadata.installedTimestamp = 0;
                }) [ ext ]);
              extensionJsonFile = pkgs.writeTextDir "${subDir}/extensions.json" extensionJson;
              combinedExtensionsDrv = pkgs.buildEnv {
                name = "vscode-extensions";
                paths = [ ext extensionJsonFile ];
              };
            in
            pkgs.runCommand "home-manager-compat-check" { } ''
              mkdir -p $out
              for f in "${combinedExtensionsDrv}/${subDir}/${ext.vscodeExtUniqueId}" \
                       "${combinedExtensionsDrv}/${subDir}/extensions.json" \
                       "${combinedExtensionsDrv}/${subDir}/${ext.vscodeExtUniqueId}/package.json"; do
                [ -e "$f" ] || { echo "Missing: $f"; exit 1; }
                cat "$f" >> $out/result 2>/dev/null || echo "$f: directory" >> $out/result
              done
            '';
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
