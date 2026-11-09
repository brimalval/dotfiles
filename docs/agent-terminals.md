# Agent terminals and orchestration

Which terminal and orchestration tools this setup uses, and why. Based on research and hands-on trials as of 2026-11-09, run as Orca orchestration workers; the full write-up with screenshots is a private artifact: https://claude.ai/artifact/BTH3TrR64TiAicB6GWvzpm

Requirements it was judged on:
- runs on Linux/WSL too (macOS-only tools are out);
- rose-pine with translucency/blur;
- keyboard-driven, with directional focus and vim-style nvim navigation;
- plain-file config that home-manager can own;
- hackable (mods/plugins/scriptable);
- packaged in Nix.

## Decision

| Role | Choice | Revisit |
|---|---|---|
| Daily terminal | Herdr app + Shepherdr | TUIOS, for a week inside kitty |
| Orchestration (one coordinator, different task per worker) | Orca | T3 Code, side by side on real tickets |

## Findings that drove it

- **Orca** (fit 3/5). Has the best orchestration of the field:
  - The coordinator ends its turn and is woken when a worker reports or asks.
  - Task DAGs, decision gates, native Linear, and a browser element picker.
  - Weak spots: settings live in SQLite, it's not in nixpkgs or Homebrew, and there's no translucency.
- **T3 Code** (3/5: orchestration 4/5, customizability 2/5). Trial of upstream 0.1.7:
  - `delegate_task` gave different tasks to worktree children. The coordinator was woken about 150 ms after each child, once per child (not batched).
  - A child's question went to the coordinator agent. A child's approval went to the human, as a card in the coordinator's view.
  - Linked environments (Labs beta) linked two servers with only a pairing code, no account. Across a link, children can't use worktree isolation, and remote approvals show only on the remote machine.
  - Customizability:
    - A rose-pine theme is a small JSON file. `keybindings.json` and the `themes/` folder can be read-only links; `settings.json` must be merged in instead.
    - No translucency, no vim or directional focus, no plugins.
  - nixpkgs `t3code` is 0.1.0, 7 releases behind, and its wrapper puts its own `codex` ahead of yours on PATH.
  - No task dependencies, no Linear.
- **TUIOS** (3/5). Trial of v0.12.1 from the upstream flake (nixpkgs is behind):
  - Emulates the herdr 0.9.5 socket. The real `herdr` CLI, the Herdr Claude hook and herdr-nvim-nav worked unchanged.
  - Shepherdr mods can't run on it: they use herdr-app's GPUI runtime and herdr-core (`hc`).
  - Inbox, one-key approvals, `fan` worktrees and ctrl+hjkl nvim handoff were all verified with real key presses.
  - Coordinator-style work uses task cards, `ask-agent`/mail and `wait-for --select --every`. It's unclear whether a worker can wake an idle coordinator: `queue` into a pane with more grants is refused.
  - No browser.
- **cmux** (4/5, then ruled out as macOS-only):
  - Ghostty config, agent badges, PR status in the sidebar, scriptable CLI.
  - Keybinds fire regardless of focus, so nvim-nav can't be seamless.
  - `background-blur = 20` showed no blur; `macos-glass-regular` did. Check this if you try Ghostty, since cmux uses its engine.
- **Rex**: closed beta whose macOS client isn't packaged for Nix. Revisit at 1.0.
- **Fallbacks**: Ghostty + tmux, or Zellij. Both are fully declarative.
- **Wound down**: Conductor (Cloud off 2026-11-20). Crystal is deprecated.
