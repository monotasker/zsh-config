# ~/.zshrc.darwin — macOS-specific config.
# Sourced by ~/.zshrc before ~/.zshrc.common.

# Homebrew prefix (Apple Silicon vs Intel).
if [[ -x /opt/homebrew/bin/brew ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -x /usr/local/bin/brew ]]; then
  export HOMEBREW_PREFIX="/usr/local"
fi

# libxml2 (Homebrew keg-only); required by some Python C extensions.
if [[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/opt/libxml2" ]]; then
  export LDFLAGS="-L$HOMEBREW_PREFIX/opt/libxml2/lib"
  export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/libxml2/include"
  export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/libxml2/lib/pkgconfig"
fi

# ueberzugpp / image.nvim need Homebrew libs on the macOS dyld fallback path.
if [[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/lib" ]]; then
  export DYLD_FALLBACK_LIBRARY_PATH="$HOMEBREW_PREFIX/lib:$DYLD_FALLBACK_LIBRARY_PATH"
fi

# Docker Desktop CLI completions. Adding to fpath here (before oh-my-zsh.sh
# is sourced in the common file) lets oh-my-zsh's internal compinit pick them up.
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)

# iTerm2 shell integration.
[[ -r "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"

# oh-my-zsh plugins to enable on macOS only (the `macos` plugin warns on Linux).
ZSH_OS_PLUGINS=(macos)

# pnpm default install location on macOS.
export PNPM_HOME="$HOME/Library/pnpm"

# Tailscale command
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# RDP to linux
frd() {
  local host="fedora.tailc44e07.ts.net"
  local user="monotasker"
  local pw
  pw=$(security find-generic-password -a "$user" -s "fedora-rdp" -w) || {
    echo "Could not read password from Keychain"
    return 1
  }
  printf '/v:%s\n/u:%s\n/p:%s\n/d:\n/cert:ignore\n/dynamic-resolution\n+clipboard\n/gfx:AVC444\n' \
    "$host" "$user" "$pw" | sdl-freerdp /args-from:stdin
  unset pw
}

# Yubikey
export YKCS11="/usr/lib/ssh-keychain.dylib"

# GPG agent socket for KCWorks Docker agent overlays (docker-compose*.agents.yml).
# Host gpg does not need this; Compose bind-mounts it into workspace/editor.
# If Docker Desktop cannot use the raw socket, point this at your bridge path.
# Leave SSH_AUTH_SOCK alone — macOS/launchd usually provides it.
if command -v gpgconf >/dev/null 2>&1; then
  _gpg_agent_sock="$(gpgconf --list-dirs agent-socket 2>/dev/null || true)"
  [[ -n "$_gpg_agent_sock" ]] && export GPG_AGENT_SOCK="$_gpg_agent_sock"
  unset _gpg_agent_sock
fi
