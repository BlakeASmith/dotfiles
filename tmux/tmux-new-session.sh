#!/usr/bin/env bash
# Create a tmux session rooted at a project/task directory (mkdir -p when needed).
# Usage:
#   tmux-new-session              interactive prompts
#   tmux-new-session /path/to/dir [session-name]
#   tmux-new-session --here       use current pane directory (from tmux) or $PWD

set -euo pipefail

sanitize_session_name() {
	local s="$1"
	s="${s//[^a-zA-Z0-9_.-]/-}"
	s="${s##-}"
	s="${s%%-}"
	if [[ -z "$s" ]]; then
		s="session"
	fi
	echo "$s"
}

unique_session_name() {
	local base="$1"
	local n="$base"
	local i=2
	while tmux has-session -t "$n" 2>/dev/null; do
		n="${base}-${i}"
		((i++)) || true
	done
	echo "$n"
}

expand_path() {
	local p="$1"
	case "$p" in
	~ | ~/*)
		p="${p/#\~/$HOME}"
		;;
	esac
	printf '%s' "$p"
}

resolve_workdir() {
	local path="$1"
	path="$(expand_path "$path")"
	path="${path%/}"
	if [[ -z "$path" ]]; then
		path="/"
	fi
	if [[ ! "$path" = /* ]]; then
		path="$(pwd -P)/$path"
	fi
	mkdir -p "$path"
	printf '%s' "$(cd "$(dirname "$path")" && pwd -P)/$(basename "$path")"
}

new_session_at() {
	local workdir="$1"
	local explicit_name="${2:-}"

	mkdir -p "$workdir"

	local base_name
	if [[ -n "$explicit_name" ]]; then
		base_name="$(sanitize_session_name "$explicit_name")"
	else
		base_name="$(sanitize_session_name "$(basename "$workdir")")"
	fi

	local session_name
	session_name="$(unique_session_name "$base_name")"

	if [[ -n "${TMUX:-}" ]]; then
		tmux new-session -ds "$session_name" -c "$workdir"
		tmux switch-client -t "$session_name"
	else
		tmux new-session -As "$session_name" -c "$workdir"
	fi
}

interactive() {
	local default_root="${TMUX_PROJECT_ROOT:-$HOME}"
	if [[ -n "${TMUX:-}" ]]; then
		default_root="$(tmux display-message -p '#{pane_current_path}' 2>/dev/null || echo "$default_root")"
	fi

	echo "New tmux session — project/task directory (missing parents are created)."
	read -r -e -p "Work directory [${default_root}]: " input
	local path="${input:-$default_root}"

	read -r -e -p "Session name (optional, default: directory name): " name_opt

	path="$(resolve_workdir "$path")"
	if [[ -n "${name_opt// }" ]]; then
		new_session_at "$path" "$name_opt"
	else
		new_session_at "$path"
	fi
}

here() {
	local dir
	if [[ -n "${TMUX:-}" ]]; then
		dir="$(tmux display-message -p '#{pane_current_path}')"
	else
		dir="${PWD:-$HOME}"
	fi
	dir="$(cd "$dir" && pwd -P)"
	new_session_at "$dir"
}

while [[ "${1:-}" == -* && "$1" != -- ]]; do
	case "$1" in
	--here)
		here
		exit 0
		;;
	--help)
		echo "Usage: tmux-new-session [--here] [--] [/path/to/project [session-name]]"
		exit 0
		;;
	*)
		echo "tmux-new-session: unknown option: $1" >&2
		exit 1
		;;
	esac
done
if [[ "${1:-}" == -- ]]; then
	shift
fi

case "${1:-}" in
"")
	if [[ -t 0 ]] && [[ -t 1 ]]; then
		interactive
	else
		echo "tmux-new-session: stdin is not a tty; pass a path or use --here" >&2
		exit 1
	fi
	;;
*)
	new_session_at "$(resolve_workdir "$1")" "${2:-}"
	;;
esac
