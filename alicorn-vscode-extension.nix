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
      echo y | vsce package -o $vsix/${pname}.zip
    '';

    preCheck = ''
      npm run lint
    '';
  };

in
vscode-utils.buildVscodeExtension {
  inherit pname version vsix;
  name = "${pname}-${version}";
  src = "${vsix}/${pname}.zip";
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
