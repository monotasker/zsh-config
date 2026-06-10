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

# No Linux-only oh-my-zsh plugins by default. Leave the array empty so the
# common file's `plugins+=("${ZSH_OS_PLUGINS[@]}")` is a no-op rather than
# referencing an unset variable.
ZSH_OS_PLUGINS=()
