#!/usr/bin/env bash
# install.sh — set up shim files in $HOME that source this managed zsh config.
#
# Safe to re-run. Existing ~/.zshrc and ~/.p10k.zsh are backed up with a
# timestamped suffix unless they already contain exactly the expected shim.
#
# Usage:
#   ./install.sh [--dry-run]

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
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      cat <<'EOF'
install.sh — set up shim files in $HOME that source this managed zsh config.

Safe to re-run. Existing ~/.zshrc and ~/.p10k.zsh are backed up with a
timestamped suffix unless they already contain exactly the expected shim.

Usage:
  ./install.sh [--dry-run]
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

install_shim() {
  local target="$1" rel_name="$2" desc="$3"
  local expected
  expected="# Managed ${desc} lives in ${display_dir}.
source \"${shim_dir}/${rel_name}\""

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -L "$target" ]]; then
      echo "skip      $target (symlink → $(readlink "$target"); leaving as-is)"
      return
    fi
    local actual
    actual=$(cat "$target")
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

echo
echo "Managed config: $display_dir"
echo "Start a new terminal or run \`exec zsh\` to load the updated config."

if [[ ! -f "$ZSH_CONFIG_DIR/local.zsh" && -f "$ZSH_CONFIG_DIR/local.zsh.example" ]]; then
  echo
  echo "Tip: create a machine-local overrides file (not committed) with:"
  echo "  cp \"$ZSH_CONFIG_DIR/local.zsh.example\" \"$ZSH_CONFIG_DIR/local.zsh\""
fi
