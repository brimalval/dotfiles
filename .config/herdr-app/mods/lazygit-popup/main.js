// lazygit in a 90% popup over the window, in the focused terminal's folder
// (the old herdr `prefix+ctrl+g` popup). Opened with `mod.open:lazygit-popup`.
// This mod only launches: it starts lazygit with hc, shows that terminal in a
// dialog, and closes its own overlay. The dialog closes when lazygit exits (q).

import { View, div } from "gpui-kit";
import { focused, spaces, hc, openOverlay, closeOverlay, props, notify } from "herdr";

export default class LazygitPopup extends View {
  init(_props, cx) {
    const self = props()?.overlay;
    cx.spawn(async (_cx) => {
      try {
        const f = focused();
        const space = spaces().find((s) => s.id === f?.space);
        const args = ["run", "--json", "--bg", "--rm", "--no-parent", "--no-notify"];
        if (f?.cwd) args.push("--cwd", f.cwd);
        if (space?.machine) args.push("--on", space.machine);
        args.push("--", "lazygit");
        const r = await hc(args);
        if (r.code !== 0) throw new Error((r.stderr || r.stdout).trim());
        const { address } = JSON.parse(r.stdout);
        openOverlay({
          kind: "dialog", width: 0.9, height: 0.9,
          layout: { type: "block", content: { terminal: address } },
        });
      } catch (e) {
        notify({ title: "lazygit", body: String(e?.message ?? e), level: "error" });
      } finally {
        if (self) closeOverlay(self);
      }
    });
  }

  render() {
    return div();
  }
}
