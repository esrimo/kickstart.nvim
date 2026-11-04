#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
REPO_URL="https://github.com/esrimo/kickstart.nvim.git"
BRANCH="esrimo-setup-rhel9"
SHARED_CONFIG_DIR="/opt/nvim-config"
NVIM_INSTALL_DIR="/opt/nvim"

# Ensure git and curl exist before anything else
if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
  sudo dnf install -y git curl
fi

# 1. Install Neovim binary to /opt/nvim if not already installed
if [ ! -x "${NVIM_INSTALL_DIR}/bin/nvim" ]; then
  echo "Installing Neovim to ${NVIM_INSTALL_DIR}..."
  curl -fLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf "${NVIM_INSTALL_DIR}"
  sudo mkdir -p "${NVIM_INSTALL_DIR}"
  sudo tar -C "${NVIM_INSTALL_DIR}" --strip-components=1 -xzf nvim-linux-x86_64.tar.gz
  rm -f nvim-linux-x86_64.tar.gz
  sudo ln -sf "${NVIM_INSTALL_DIR}/bin/nvim" /usr/local/bin/nvim
fi

# 2. Populate /opt/nvim-config (either from existing local clone or fresh clone)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"

if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/.git" ] && [ "$SCRIPT_DIR" != "$SHARED_CONFIG_DIR" ]; then
  # You manually cloned the repo somewhere else and ran ./initSetup.sh
  echo "Moving local clone from ${SCRIPT_DIR} to ${SHARED_CONFIG_DIR}..."
  sudo rm -rf "${SHARED_CONFIG_DIR}"
  sudo cp -a "${SCRIPT_DIR}" "${SHARED_CONFIG_DIR}"
  sudo git -C "${SHARED_CONFIG_DIR}" checkout "${BRANCH}"
elif [ ! -d "${SHARED_CONFIG_DIR}/.git" ]; then
  # Executed via curl | bash or outside the repo
  echo "Cloning ${REPO_URL} (${BRANCH}) into ${SHARED_CONFIG_DIR}..."
  sudo rm -rf "${SHARED_CONFIG_DIR}"
  sudo git clone --branch "${BRANCH}" "${REPO_URL}" "${SHARED_CONFIG_DIR}"
else
  echo "Updating existing repo in ${SHARED_CONFIG_DIR}..."
  sudo git -C "${SHARED_CONFIG_DIR}" fetch origin "${BRANCH}"
  sudo git -C "${SHARED_CONFIG_DIR}" checkout "${BRANCH}"
  sudo git -C "${SHARED_CONFIG_DIR}" pull origin "${BRANCH}"
fi

# Allow git operations across users on the shared directory
sudo git config --system --add safe.directory "${SHARED_CONFIG_DIR}"

# 3. Symlink ~/.config/nvim -> /opt/nvim-config for root and ssm-user
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
for USER_HOME in /root /home/ssm-user; do
  if [ -d "$USER_HOME" ]; then
    sudo mkdir -p "${USER_HOME}/.config"
    TARGET_LINK="${USER_HOME}/.config/nvim"
    # Back up if it's a real directory (not a symlink)
    if [ -d "$TARGET_LINK" ] && [ ! -L "$TARGET_LINK" ]; then
      sudo mv "$TARGET_LINK" "${TARGET_LINK}.bak_${TIMESTAMP}"
    fi
    sudo ln -sfn "${SHARED_CONFIG_DIR}" "$TARGET_LINK"
  fi
done

# 4. Run finishInstallation.sh to install packages, tree-sitter, and sync plugins
sudo chmod +x "${SHARED_CONFIG_DIR}/finishInstallation.sh"
sudo "${SHARED_CONFIG_DIR}/finishInstallation.sh"

# 5. Replicate compiled plugin data (blink.cmp .so, lazy packages) to ssm-user
if id "ssm-user" >/dev/null 2>&1; then
  sudo mkdir -p /home/ssm-user/.local/share
  sudo rm -rf /home/ssm-user/.local/share/nvim
  sudo cp -a /root/.local/share/nvim /home/ssm-user/.local/share/
  sudo chown -R ssm-user:ssm-user "${SHARED_CONFIG_DIR}" /home/ssm-user/.config /home/ssm-user/.local
fi

echo "Setup complete: $(nvim --version | head -n 1) configured in ${SHARED_CONFIG_DIR}."
