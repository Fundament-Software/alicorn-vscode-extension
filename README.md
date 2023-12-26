TODO: Fill in README template fields

# Nix usage

flake:

```nix
# In flake.nix
inputs.alicorn-vscode-extension = {
	url = "github:Fundament-Software/alicorn-vscode-extension";
	# optionally follow your own nixpkgs/flake-utils inputs
	inputs.nixpkgs.follows = "nixpkgs";
	inputs.flake-utils.follows = "flake-utils";
};

# Where you configure your vscode in home-manager
# alicorn-vscode-extension needs to be the alicorn-vscode-extension flake input
programs.vscode.extensions = [
	alicorn-vscode-extension.packages.${pkgs.system}.alicorn-vscode-extension
];
```

non-flake:

```nix
# Fetch the extension
let alicorn-vscode-extension = pkgs.fetchFromGitHub {
  owner = "Fundament-Software";
  repo = "alicorn-vscode-extension";
  ## Update rev and hash
  rev = "some rev";
  hash = "sha256-1ygmGX/FIK1wBPoVnnDJq1d2ptP7/ZxgCNZKUsCAHaQ=";
}; 

# Where you configure your vscode in home-manager
programs.vscode.extensions = [
	(pkgs.callPackage "${alicorn-vscode-extension}/alicorn-vscode-extension.nix" {};)
];
```

# alicorn-vscode-extension README

vscode extension for the Alicorn language

## Features

Describe specific features of your extension including screenshots of your extension in action. Image paths are relative to this README file.

For example if there is an image subfolder under your extension project workspace:

\!\[feature X\]\(images/feature-x.png\)

> Tip: Many popular extensions utilize animations. This is an excellent way to show off your extension! We recommend short, focused animations that are easy to follow.

## Requirements

None yet. Likely needs an alicorn language server on PATH in the future.

## Extension Settings

Include if your extension adds any VS Code settings through the `contributes.configuration` extension point.

For example:

This extension contributes the following settings:

* `myExtension.enable`: Enable/disable this extension.
* `myExtension.thing`: Set to `blah` to do something.

## Release Notes

Not yet published

### 1.0.0

Initial release of ...
