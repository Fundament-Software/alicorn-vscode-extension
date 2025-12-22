{ lib
, vscode-utils
, esbuild
, pkg-config
, libsecret
, buildNpmPackage
, vsce
}:

let
  pname = "alicorn-vscode-extension";
  publisher = "fundament";

  version = "unstable-2023-12-25";

  src = ./.;

  # Cursed: detect whether nixpkgs expects .vsix or .zip
  # https://github.com/nix-community/nix-vscode-extensions/pull/164
  dummyExt = vscode-utils.buildVscodeExtension {
    pname = "";
    version = "";
    src = "";
    vscodeExtUniqueId = "";
    vscodeExtPublisher = "";
    vscodeExtName = "";
  };
  dummyDeps = builtins.map (x: x.name) dummyExt.nativeBuildInputs;
  isVsix = builtins.elem "unpack-vsix-setup-hook" dummyDeps;
  fileExtension = if isVsix then "vsix" else "zip";

  vsix = buildNpmPackage {
    pname = "${pname}-vsix";
    inherit version src;

    outputs = [ "vsix" "out" ];

    nativeBuildInputs = [
      # jq
      # moreutils
      esbuild
      # Required by `keytar`, which is a dependency of `vsce`.
      pkg-config
      libsecret
      vsce
    ];

    npmDepsHash = "sha256-EBmKpeaxlusNpW02FHqth39eoH4Y57SKKSsfqOKT0B0=";

    dontNpmBuild = true;
    postBuild = ''
      npm run compile
      mkdir -p $vsix
      echo y | vsce package -o $vsix/${pname}.${fileExtension}
    '';

    preCheck = ''
      npm run lint
    '';
  };

in
vscode-utils.buildVscodeExtension {
  inherit pname version vsix;
  name = "${pname}-${version}";
  src = "${vsix}/${pname}.${fileExtension}";
  vscodeExtUniqueId = "${publisher}.${pname}";
  vscodeExtPublisher = publisher;
  vscodeExtName = pname;

  meta = {
    description = "vscode extension for the Alicorn language";
    homepage = "https://github.com/Fundament-Software/alicorn-vscode-extension";
    license = [ lib.licenses.asl20 ];
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
