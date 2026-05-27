#!/usr/bin/env bash
# install.sh — set up shim files in $HOME that source this managed zsh config.
#
# Safe to re-run. Existing ~/.zshrc and ~/.p10k.zsh are backed up with a
# timestamped suffix unless they already contain exactly the expected shim.
#
# Usage:
#   ./install.sh [--dry-run] [--with-omz] [--with-plugins]

set -euo pipefail

# Resolve the directory containing this script, following symlinks. macOS ships
# without GNU coreutils' `readlink -f`, so do it by hand.
script_path="$0"
while [[ -L "$script_path" ]]; do
  link_target=$(readlink "$script_path")
  if [[ "$link_target" = /* ]]; then
    script_path="$link_target"
  else
    script_path="$(dirname "$script_path")/$link_target"
  fi
done
ZSH_CONFIG_DIR="$(cd "$(dirname "$script_path")" && pwd)"

# When the managed config lives under $HOME, write shims using $HOME/... rather
# than the absolute path. This keeps the generated shims clean and survives a
# username or home-directory rename.
if [[ "$ZSH_CONFIG_DIR" == "$HOME"/* ]]; then
  shim_dir='$HOME/'"${ZSH_CONFIG_DIR#"$HOME"/}"
  display_dir="~/${ZSH_CONFIG_DIR#"$HOME"/}"
else
  shim_dir="$ZSH_CONFIG_DIR"
  display_dir="$ZSH_CONFIG_DIR"
fi

DRY_RUN=0
WITH_OMZ=0
WITH_PLUGINS=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --with-omz) WITH_OMZ=1 ;;
    --with-plugins) WITH_PLUGINS=1 ;;
    -h|--help)
      cat <<'EOF'
install.sh — set up shim files in $HOME that source this managed zsh config.

Safe to re-run. Existing ~/.zshrc and ~/.p10k.zsh are backed up with a
timestamped suffix unless they already contain exactly the expected shim.

Usage:
  ./install.sh [--dry-run] [--with-omz] [--with-plugins]

Options:
  --dry-run        Print what would happen without making changes.
  --with-omz      Clone oh-my-zsh into ~/.oh-my-zsh if missing.
  --with-plugins  Clone external theme/plugins needed by this config:
                    powerlevel10k
                    zsh-autosuggestions
                    zsh-syntax-highlighting
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

required_files=(zshrc common.zsh darwin.zsh linux.zsh p10k.zsh)
missing=0
for f in "${required_files[@]}"; do
  if [[ ! -f "$ZSH_CONFIG_DIR/$f" ]]; then
    echo "Missing expected file: $ZSH_CONFIG_DIR/$f" >&2
    missing=1
  fi
done
(( missing == 0 )) || exit 1

timestamp=$(date +%Y%m%d-%H%M%S)

clone_repo() {
  local url="$1" dest="$2" label="$3"

  if [[ -d "$dest/.git" ]]; then
    echo "ok        $label ($dest already installed)"
    return
  fi

  if [[ -e "$dest" ]]; then
    echo "skip      $label ($dest exists but is not a git checkout)" >&2
    return
  fi

  if (( DRY_RUN )); then
    echo "would clone $label -> $dest"
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "git is required to install $label" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$dest")"
  git clone --depth=1 "$url" "$dest"
  echo "installed $label ($dest)"
}

install_omz() {
  clone_repo \
    "https://github.com/ohmyzsh/ohmyzsh.git" \
    "$HOME/.oh-my-zsh" \
    "oh-my-zsh"
}

install_external_plugins() {
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [[ ! -d "$HOME/.oh-my-zsh" && $WITH_OMZ -eq 0 ]]; then
    echo "oh-my-zsh is not installed. Re-run with --with-omz --with-plugins." >&2
    exit 1
  fi

  clone_repo \
    "https://github.com/romkatv/powerlevel10k.git" \
    "$zsh_custom/themes/powerlevel10k" \
    "powerlevel10k"

  clone_repo \
    "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$zsh_custom/plugins/zsh-autosuggestions" \
    "zsh-autosuggestions"

  clone_repo \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$zsh_custom/plugins/zsh-syntax-highlighting" \
    "zsh-syntax-highlighting"
}

install_shim() {
  local target="$1" rel_name="$2" desc="$3"
  local expected
  expected="# Managed ${desc} lives in ${display_dir}.
if [ -z \"\${ZSH_VERSION:-}\" ]; then
  printf '%s\n' \"This config is for zsh. Run: exec zsh\" >&2
  return 0 2>/dev/null || exit 0
fi

source \"${shim_dir}/${rel_name}\""

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -L "$target" ]]; then
      echo "skip      $target (symlink → $(readlink "$target"); leaving as-is)"
      return
    fi
    local actual
    actual=$(<"$target")
    if [[ "$actual" == "$expected" ]]; then
      echo "ok        $target (already a shim)"
      return
    fi
    local backup="${target}.bak.${timestamp}"
    if (( DRY_RUN )); then
      echo "would back up $target -> $backup"
      echo "would write   $target"
    else
      cp "$target" "$backup"
      printf '%s\n' "$expected" > "$target"
      echo "updated   $target (backup: $backup)"
    fi
  else
    if (( DRY_RUN )); then
      echo "would write $target"
    else
      printf '%s\n' "$expected" > "$target"
      echo "wrote     $target"
    fi
  fi
}

install_shim "$HOME/.zshrc"    zshrc    "zsh config"
install_shim "$HOME/.p10k.zsh" p10k.zsh "Powerlevel10k config"

if (( WITH_OMZ )); then
  install_omz
fi

if (( WITH_PLUGINS )); then
  install_external_plugins
fi

echo
echo "Managed config: $display_dir"
echo "Start a new terminal or run \`exec zsh\` to load the updated config."

if [[ ! -f "$ZSH_CONFIG_DIR/local.zsh" && -f "$ZSH_CONFIG_DIR/local.zsh.example" ]]; then
  echo
  echo "Tip: create a machine-local overrides file (not committed) with:"
  echo "  cp \"$ZSH_CONFIG_DIR/local.zsh.example\" \"$ZSH_CONFIG_DIR/local.zsh\""
fi
