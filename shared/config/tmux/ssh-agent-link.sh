#!/bin/sh
#
# Keep SSH agent forwarding working in tmux across reconnects.
#
# Called from tmux hooks (see .tmux.conf):
#   ssh-agent-link.sh <session_id>
#
# Each SSH login gets a new forwarded agent socket with a random path, so shells
# in a long-lived tmux session end up pointing at a dead socket after you
# reconnect. This script gives each tmux session a stable symlink
# (~/.ssh/agent-tmux-<id>) that is re-pointed at the current login's agent on
# every create/attach. Shells use the symlink via ssh-agent-shell.sh, sourced
# from your shell rc.
#
# Links are per tmux session, so multiple people sharing one account (e.g.
# "deploy") each keep their own agent as long as they use their own session.

session_id=$1

[ -n "$session_id" ] || exit 0

link="$HOME/.ssh/agent-tmux-$(printf '%s' "$session_id" | tr -d '$')"

# On attach, tmux copies the client's SSH_AUTH_SOCK into the session environment
# (via the default update-environment option), so this is the attaching login's socket.
sock=$(tmux show-environment -t "$session_id" SSH_AUTH_SOCK 2>/dev/null | sed -n 's/^SSH_AUTH_SOCK=//p')

# Only act if the login actually forwarded a working agent
if [ -S "$sock" ] && [ "$sock" != "$link" ]; then
	mkdir -p -m 700 "$HOME/.ssh"
	# Also point the session environment at the link, so windows started with a
	# command (which don't run your shell rc) get it too. Shells pick it up from
	# ssh-agent-shell.sh, which also covers the first pane of a new session.
	ln -sfn "$sock" "$link" && tmux set-environment -t "$session_id" SSH_AUTH_SOCK "$link"
fi

# Remove links whose agent socket is gone (that login disconnected)
for f in "$HOME"/.ssh/agent-tmux-*; do
	[ -L "$f" ] && [ ! -e "$f" ] && rm -f "$f"
done

exit 0
