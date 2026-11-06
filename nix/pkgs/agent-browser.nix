# Pins agent-browser to the exact version Herdr wants, from the prebuilt GitHub release binary.
# To bump: see nix/README.md or docs/cli-version-management.md#bumping-the-pin.
{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "agent-browser";
  version = "0.41.1"; # keep equal to PIN= in ~/.local/bin/herdr-browser

  src = fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/releases/download/v${finalAttrs.version}/agent-browser-darwin-arm64";
    hash = "sha256-Y7Cpe4WlS0ybKHExivdBBMKbgKvVB7U6MDFohOBihUs=";
  };

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/agent-browser
    runHook postInstall
  '';

  meta = {
    description = "Browser automation CLI for AI agents (pinned for Herdr)";
    homepage = "https://agent-browser.dev";
    license = lib.licenses.asl20; # package.json: Apache-2.0
    platforms = [ "aarch64-darwin" ];
    mainProgram = "agent-browser";
  };
})
