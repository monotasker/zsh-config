# ~/.zshrc.common — cross-platform zsh config.
# Sourced by ~/.zshrc after any ~/.zshrc.${ZSH_OS} file has run.

# Prepend a directory to PATH if not already present (and the arg is non-empty).
prepend_path() {
  [[ -z "$1" ]] && return
  case ":$PATH:" in
  *":$1:"*) ;;
  *) export PATH="$1:$PATH" ;;
  esac
}

# Base PATH. OS-specific files may have already prepended Homebrew etc.
export PATH="$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH"

# pyenv (Python version manager)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && prepend_path "$PYENV_ROOT/bin"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"

# vim keybindings in the terminal
bindkey -v

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Cross-platform plugin list. Add wisely — too many plugins slow shell startup.
plugins=(
  aws
  colored-man-pages
  colorize
  copybuffer
  copyfile
  copypath
  dirhistory
  docker
  docker-compose
  gh
  git
  history
  npm
  nvm
  pip
  sudo
  uv
  vi-mode
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# OS-specific files may set ZSH_OS_PLUGINS (e.g. `macos` plugin on Darwin).
if [[ -n "${ZSH_OS_PLUGINS+x}" ]]; then
  plugins+=("${ZSH_OS_PLUGINS[@]}")
fi

source "$ZSH/oh-my-zsh.sh"

# KC Works helper aliases. Assumes ~/Development/knowledge-commons-tools exists
# and ~/.ssh/msu-dev-2022.pem is present on this machine.
alias get_kc_ip='uv run --project "$HOME/Development/knowledge-commons-tools" "$HOME/Development/knowledge-commons-tools/get_ip.py"'
alias get_kc_ips='uv run --project "$HOME/Development/knowledge-commons-tools" "$HOME/Development/knowledge-commons-tools/get_all_ips.py"'
alias ssh_prod='ssh -i "$HOME/.ssh/msu-dev-2022.pem" ec2-user@$(get_kc_ip kcworks-prod-2 2>/dev/null | grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")'
alias ssh_staging='ssh -i "$HOME/.ssh/msu-dev-2022.pem" ec2-user@$(get_kc_ip kcworks-staging-3 2>/dev/null | grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")'

# dotsync
alias dotsync='bash ~/.local/bin/dotsync/dotsync.sh'

# NVM (Node version manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# txtai segfault workaround
export OMP_NUM_THREADS=1

# zoxide (smarter cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# rbenv (Ruby version manager)
command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"

# direnv (per-directory env)
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# pnpm: PNPM_HOME is set by the OS-specific file because the default install
# location differs between macOS (~/Library/pnpm) and Linux (~/.local/share/pnpm).
prepend_path "$PNPM_HOME"

# Go binaries
if command -v go >/dev/null 2>&1; then
  prepend_path "$(go env GOPATH)/bin"
fi

# UV config
export UV_PYTHON_DOWNLOADS=automatic

# Pi agent helpers
alias pi-start='read $HOME/.pi-system-profile.md && echo "System profile loaded. Using custom context."'
alias websearch='bash $HOME/tools/web_search.sh'
