#!/usr/bin/env bash
set -euo pipefail

NVIM_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAZY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy"

# ------------------------------------------------------------------------------
# 1. Install OS dependencies & Rust/Cargo (RHEL/Fedora vs Debian/Ubuntu)
# ------------------------------------------------------------------------------
if command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm 2>/dev/null || true
  sudo dnf install -y git make gcc gcc-c++ unzip ripgrep fd-find tar curl nodejs npm xdg-utils cargo rust
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y git make gcc g++ unzip ripgrep fd-find tar curl nodejs npm xdg-utils cargo rustc
fi

# ------------------------------------------------------------------------------
# 2. Remove broken npm tree-sitter-cli (GLIBC_2.35 error) & build natively
# ------------------------------------------------------------------------------
sudo npm uninstall -g tree-sitter-cli 2>/dev/null || true
export PATH="$HOME/.cargo/bin:$PATH"
if ! grep -q '.cargo/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"
fi

if ! tree-sitter --version >/dev/null 2>&1; then
  cargo install tree-sitter-cli --locked
fi
# Symlink to /usr/local/bin so Neovim and sudo always find it
sudo ln -sf "$HOME/.cargo/bin/tree-sitter" /usr/local/bin/tree-sitter

# ------------------------------------------------------------------------------
# 3. Pre-clone kulala.nvim with submodules to avoid old Git worktree bug
# ------------------------------------------------------------------------------
mkdir -p "$LAZY_DIR"
if [ ! -d "$LAZY_DIR/kulala.nvim/.git" ]; then
  rm -rf "$LAZY_DIR/kulala.nvim"
  git clone --recurse-submodules https://github.com/mistweaverco/kulala.nvim.git "$LAZY_DIR/kulala.nvim"
fi

# ------------------------------------------------------------------------------
# 4. Configure healthcheck fixes (providers, markdown.mdx, lazy luarocks)
# ------------------------------------------------------------------------------
# Disable luarocks in init.lua if not already disabled
if grep -q "rocks = { enabled = false }" "$NVIM_CONFIG_DIR/init.lua" 2>/dev/null; then
  true
else
  sed -i 's/require(.lazy.).setup(\[/require("lazy").setup(\[/; s/}, {/}, { rocks = { enabled = false }, /' "$NVIM_CONFIG_DIR/init.lua" 2>/dev/null || true
fi

# Ensure health fixes are loaded via plugin/ directory (auto-sourced by Neovim)
mkdir -p "$NVIM_CONFIG_DIR/plugin"
cat << 'LUA' > "$NVIM_CONFIG_DIR/plugin/health_fixes.lua"
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

vim.filetype.add({
  extension = {
    mdx = 'markdown.mdx',
  },
})
LUA

# ------------------------------------------------------------------------------
# 5. Sync Lazy plugins & compile blink_cmp_fuzzy natively against system glibc
# ------------------------------------------------------------------------------
nvim --headless "+Lazy! sync" +qa

if [ -d "$LAZY_DIR/blink.cmp" ]; then
  echo "Building blink_cmp_fuzzy from source for native glibc compatibility..."
  (
    cd "$LAZY_DIR/blink.cmp"
    cargo build --release
  )
fi

# ------------------------------------------------------------------------------
# 6. Verification
# ------------------------------------------------------------------------------
echo "=============================================================================="
echo "Verification:"
echo "  tree-sitter-cli : $(tree-sitter --version)"
echo "  blink_cmp_fuzzy : $(ls -lh "$LAZY_DIR/blink.cmp/target/release/libblink_cmp_fuzzy.so")"
echo "=============================================================================="

