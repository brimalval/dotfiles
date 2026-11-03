// Seamless ctrl+h/j/k/l across Neovim splits and Herdr panes
// (vim-tmux-navigator / herdr-nvim-nav, for herdr-app).
//
// keys.json binds ctrl-h/j/k/l to "nvim-nav.<dir>". When the focused pane is
// running Neovim, the key is handed to it (`hc keys`); Neovim moves between its
// own splits and, at an edge, calls `herdr-app do pane.go` itself (see
// ~/.config/nvim/lua/brimalval/plugins/init.lua). Anywhere else, Herdr's focus
// moves with pane.go.
//
// Draws nothing: it lives in an empty 0px block only so it can receive keys.

import { View, div } from "gpui-kit";
import { focused, panes, run, hc, nextCommand } from "herdr";

const KEY = { left: "ctrl+h", down: "ctrl+j", up: "ctrl+k", right: "ctrl+l" };
const VIM = new Set(["nvim", "vim"]);

export default class NvimNav extends View {
  init(_props, cx) {
    cx.spawn(async (_cx) => {
      for (;;) {
        const dir = await nextCommand();
        if (!KEY[dir]) continue;
        try { await this.nav(dir); } catch (e) { console.log(`nvim-nav: ${e}`); }
      }
    });
  }

  async nav(dir) {
    const f = focused();
    const pane = f?.pane ? panes().find((p) => p.pane === f.pane) : null;
    if (f?.terminal && pane && VIM.has(pane.program?.key)) {
      await hc(["keys", f.terminal, KEY[dir]]);
    } else {
      run("pane.go", { direction: dir });
    }
  }

  render() {
    return div();
  }
}
