# Keep SSH agent forwarding working in tmux after reconnecting.
#
# Source this from your shell rc (bash or zsh). Inside tmux, it points
# SSH_AUTH_SOCK at the session's stable link (~/.ssh/agent-tmux-<id>), which
# ssh-agent-link.sh (run from tmux hooks) keeps pointed at the most recently
# attached login's forwarded agent.
#
# Doing this when each shell starts (instead of only via the tmux session
# environment) covers the first pane of a new session too, which starts before
# tmux's session-created hook runs.

if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ] && [ -n "${SSH_AUTH_SOCK:-}" ]; then
	_tmux_session_id=$(tmux display-message -p -t "$TMUX_PANE" '#{session_id}' 2>/dev/null)
	if [ -n "$_tmux_session_id" ]; then
		export SSH_AUTH_SOCK="$HOME/.ssh/agent-tmux-$(printf '%s' "$_tmux_session_id" | tr -d '$')"
	fi
	unset _tmux_session_id
fi
