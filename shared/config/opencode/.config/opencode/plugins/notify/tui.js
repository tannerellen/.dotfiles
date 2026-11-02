import { appendFileSync } from "fs";

const osc99 = (msg) => `\x1b]99;;${msg}\x1b\\`;

const wrap = (seq) =>
  process.env.TMUX
    ? `\x1bPtmux;${seq.replaceAll("\x1b", "\x1b\x1b")}\x1b\\`
    : seq;

export default {
  id: "notify.tui",
  setup(context) {
    return context.data.on("session.idle", () => {
      try {
        appendFileSync("/dev/tty", wrap(osc99("opencode finished")));
      } catch {}
    });
  },
};
