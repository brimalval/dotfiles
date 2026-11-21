# win32yank: the Windows clipboard from WSL (a Windows .exe, run through WSL interop). Not in nixpkgs.
# nvim uses it on WSL (.config/nvim/lua/brimalval/core/options.lua); WSLg's wl-copy route is slower and
# breaks whenever WSLg's compositor crashes. Upstream hasn't released since 2023.
{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "win32yank";
  version = "0.1.1";

  src = fetchzip {
    url = "https://github.com/equalsraf/win32yank/releases/download/v${finalAttrs.version}/win32yank-x64.zip";
    hash = "sha256-4ivE1cYZhYs4ibx5oiYMOhbse9bdOomk7RjgdVl5lD0="; # of the unpacked zip (fetchzip), not the .zip file
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 $src/win32yank.exe $out/bin/win32yank.exe
    runHook postInstall
  '';

  meta = {
    description = "Windows clipboard tool, used from WSL";
    homepage = "https://github.com/equalsraf/win32yank";
    license = lib.licenses.isc;
    platforms = [ "x86_64-linux" ];
    mainProgram = "win32yank.exe";
  };
})
