#!/usr/bin/env bash
set -euo pipefail

NVIM_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAZY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy"

# ------------------------------------------------------------------------------
# 1. Detect existing Rust/Cargo (respecting /opt/.cargo, $CARGO_HOME, or PATH)
# ------------------------------------------------------------------------------
if [ -z "${CARGO_HOME:-}" ]; then
  if [ -d "/opt/.cargo/bin" ]; then
    export CARGO_HOME="/opt/.cargo"
    export RUSTUP_HOME="${RUSTUP_HOME:-/opt/.rustup}"
  else
    export CARGO_HOME="$HOME/.cargo"
  fi
fi
export PATH="$CARGO_HOME/bin:$PATH"

RUST_PKGS=()
if ! command -v cargo >/dev/null 2>&1 || ! command -v rustc >/dev/null 2>&1; then
  if command -v dnf >/dev/null 2>&1; then
    RUST_PKGS=(cargo rust)
  elif command -v apt-get >/dev/null 2>&1; then
    RUST_PKGS=(cargo rustc)
  fi
else
  echo "Using existing Rust toolchain: $(rustc --version) at $(command -v rustc)"
fi

# ------------------------------------------------------------------------------
# 2. Install OS dependencies (only installs rust/cargo if missing)
# ------------------------------------------------------------------------------
if command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y "https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm" 2>/dev/null || true
  sudo dnf install -y git make gcc gcc-c++ unzip ripgrep fd-find tar curl nodejs npm xdg-utils "${RUST_PKGS[@]}"
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y git make gcc g++ unzip ripgrep fd-find tar curl nodejs npm xdg-utils "${RUST_PKGS[@]}"
fi

if ! grep -q "$CARGO_HOME/bin" "$HOME/.bashrc" 2>/dev/null; then
  echo "export PATH=\"$CARGO_HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
fi

# ------------------------------------------------------------------------------
# 3. Remove broken npm tree-sitter-cli (GLIBC_2.35 error) & build natively
# ------------------------------------------------------------------------------
sudo npm uninstall -g tree-sitter-cli 2>/dev/null || true

if ! command -v tree-sitter >/dev/null 2>&1 || ! tree-sitter --version >/dev/null 2>&1; then
  cargo install tree-sitter-cli --locked
fi

# Copy actual binary to /usr/local/bin so all users (e.g. ssm-user) can execute it
TS_BIN="$(command -v tree-sitter || echo "$CARGO_HOME/bin/tree-sitter")"
if [ -f "$TS_BIN" ] && [ "$(realpath "$TS_BIN")" != "/usr/local/bin/tree-sitter" ]; then
  sudo rm -f /usr/local/bin/tree-sitter
  sudo cp "$TS_BIN" /usr/local/bin/tree-sitter
  sudo chmod 755 /usr/local/bin/tree-sitter
fi

# ------------------------------------------------------------------------------
# 4. Pre-clone kulala.nvim with submodules to avoid old Git worktree bug
# ------------------------------------------------------------------------------
mkdir -p "$LAZY_DIR"
if [ ! -d "$LAZY_DIR/kulala.nvim/.git" ]; then
  rm -rf "$LAZY_DIR/kulala.nvim"
  git clone --recurse-submodules https://github.com/mistweaverco/kulala.nvim.git "$LAZY_DIR/kulala.nvim"
fi

# ------------------------------------------------------------------------------
# 5. Configure healthcheck fixes (providers, markdown.mdx, lazy luarocks)
# ------------------------------------------------------------------------------
if ! grep -q "rocks = { enabled = false }" "$NVIM_CONFIG_DIR/init.lua" 2>/dev/null; then
  sed -i 's/require(.lazy.).setup(\[/require("lazy").setup(\[/; s/}, {/}, { rocks = { enabled = false }, /' "$NVIM_CONFIG_DIR/init.lua" 2>/dev/null || true
fi

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
# 6. Sync Lazy plugins & compile blink_cmp_fuzzy natively against system glibc
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
# 7. Verification
# ------------------------------------------------------------------------------
echo "=============================================================================="
echo "Verification:"
echo "  rustc           : $(rustc --version) ($(command -v rustc))"
echo "  tree-sitter-cli : $(/usr/local/bin/tree-sitter --version)"
echo "  blink_cmp_fuzzy : $(ls -lh "$LAZY_DIR/blink.cmp/target/release/libblink_cmp_fuzzy.so")"
echo "=============================================================================="
