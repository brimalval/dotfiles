# AeroSpace patches

AeroSpace v0.21.3-Beta crashes ("MacWindow is already unbound") when a `focus` hotkey runs over a
workspace with floating windows: upstream [#1311](https://github.com/nikitabobko/AeroSpace/issues/1311),
open, no release since July 2026. We moved to OmniWM (`programs.omniwm` in `nix/home.nix`) instead of
carrying a build; this patch is kept in case we go back.

`patches/0001-focus-floating-windows-race.patch` applies to tag `v0.21.3-Beta`. It splits
`makeFloatingWindowsSeenAsTiling` into an AX-read phase and one synchronous tree-mutation phase that
re-validates every window and target, so overlapping focus commands can neither double-unbind a window
nor insert at a stale index. Stricter than upstream PRs #2228, #2281 and #2342. It compiles; the tests need full Xcode (XCTest).

Building it needs Xcode and a self-signed `aerospace-codesign-certificate` (AeroSpace's
dev-docs/development.md), so Accessibility permission survives rebuilds. Remove the `aerospace` cask from
`nix/darwin.nix` first, or the next switch reinstalls the stock app over the patched one.
