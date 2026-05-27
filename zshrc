if [ -z "${ZSH_VERSION:-}" ]; then
  printf '%s\n' "This config is for zsh. Run: exec zsh" >&2
  return 0 2>/dev/null || exit 0
fi

# Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Detect OS for selecting an OS-specific config file below.
export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"

case "$OSTYPE" in
  darwin*) export ZSH_OS="darwin" ;;
  linux*)  export ZSH_OS="linux"  ;;
  *)       export ZSH_OS="unknown" ;;
esac

# OS-specific environment (Homebrew paths, dyld vars, PNPM_HOME, extra oh-my-zsh
# plugins, etc.). Loaded first so the common file can use anything it sets,
# including the ZSH_OS_PLUGINS array, which is appended to `plugins` before
# oh-my-zsh.sh is sourced.
[[ -r "$ZSH_CONFIG_DIR/${ZSH_OS}.zsh" ]] && source "$ZSH_CONFIG_DIR/${ZSH_OS}.zsh"

# Cross-platform config: PATH, oh-my-zsh, aliases, tool inits.
[[ -r "$ZSH_CONFIG_DIR/common.zsh" ]] && source "$ZSH_CONFIG_DIR/common.zsh"

# Machine-specific or untracked overrides (not synced across machines).
[[ -r "$ZSH_CONFIG_DIR/local.zsh" ]] && source "$ZSH_CONFIG_DIR/local.zsh"

# Powerlevel10k configuration. To customize, run `p10k configure` or edit p10k.zsh.
[[ -r "$ZSH_CONFIG_DIR/p10k.zsh" ]] && source "$ZSH_CONFIG_DIR/p10k.zsh"
