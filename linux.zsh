# ~/.zshrc.linux — Linux-specific config (tested target: Fedora).
# Sourced by ~/.zshrc before ~/.zshrc.common.

# libxml2 headers come from `sudo dnf install libxml2-devel`. pkg-config
# finds them automatically, so no LDFLAGS / CPPFLAGS overrides are needed.

# Docker completions on Fedora typically come from the docker-ce or podman
# packages and live in /usr/share/zsh/site-functions, which is already in
# zsh's default fpath. No manual fpath additions needed by default.

# pnpm default install location on Linux (when installed via the standalone
# installer or `npm i -g pnpm`). Adjust if you use a distro package.
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME/bin:"*) ;;
*) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# Put cargo on the system PATH
export PATH="$HOME/.cargo/bin:$PATH"

# No Linux-only oh-my-zsh plugins by default. Leave the array empty so the
# common file's `plugins+=("${ZSH_OS_PLUGINS[@]}")` is a no-op rather than
# referencing an unset variable.
ZSH_OS_PLUGINS=()

# Enable GPG over SSH
export GPG_TTY=$(tty)
if [ -n "${SSH_CONNECTION:-}" ]; then
  gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
fi

# RDP credentials properly set on ssh login?
if [[ -n "${SSH_CONNECTION:-}" ]] && command -v refresh-rdp-credentials.sh &>/dev/null; then
  refresh-rdp-credentials.sh --check-only || {
    echo "RDP credentials may need refresh: refresh-rdp-credentials.sh --force"
  }
fi

# To ensure ssh-agent is active to unlock ssh keys for session
if [[ -n "${SSH_CONNECTION:-}" ]]; then
  unset SSH_AUTH_SOCK SSH_AGENT_PID
fi

if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  eval "$(ssh-agent -s)" >/dev/null
fi

if [ -z "${SSH_AUTH_SOCK:-}" ]; then
  export SSH_AUTH_SOCK=$(find "$HOME/.ssh/agent" -name "s.*" | head -1)
  export SSH_AGENT_PID=$(pgrep -u "$USER" ssh-agent)
fi

if [[ -n "${SSH_CONNECTION:-}" ]]; then
  # ensure TERM is set so that ssh-agent recognizes an SSH session
  [[ "$TERM" == tmux* ]] && export TERM=xterm-256color
  # lock ssh keys again on exit
  trap '[[ -n "$SSH_AGENT_PID" ]] && ssh-agent -k >/dev/null 2>&1' EXIT
fi

# Yubikey ssh piv handler
export YKCS11="/usr/lib64/libykcs11.dylib"
