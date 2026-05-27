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
