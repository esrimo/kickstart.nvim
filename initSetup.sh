#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
REPO_URL="git@github.com:esrimo/kickstart.nvim.git"
BRANCH="esrimo-setup-rhel9"
SHARED_CONFIG_DIR="/opt/nvim-config"
NVIM_INSTALL_DIR="/opt/nvim"

# Ensure git and curl exist
if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
  dnf install -y git curl
fi

# 1. Install Neovim binary to /opt/nvim if not already installed
if [ ! -x "${NVIM_INSTALL_DIR}/bin/nvim" ]; then
  echo "Installing Neovim to ${NVIM_INSTALL_DIR}..."
  curl -fLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  rm -rf "${NVIM_INSTALL_DIR}"
  mkdir -p "${NVIM_INSTALL_DIR}"
  tar -C "${NVIM_INSTALL_DIR}" --strip-components=1 -xzf nvim-linux-x86_64.tar.gz
  rm -f nvim-linux-x86_64.tar.gz
  ln -sf "${NVIM_INSTALL_DIR}/bin/nvim" /usr/local/bin/nvim
fi

# 2. Populate /opt/nvim-config from local clone (no network/SSH calls needed if already cloned)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"

# Allow git operations across users before checking branch
git config --system --replace-all safe.directory "${SHARED_CONFIG_DIR}"

if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/.git" ] && [ "$SCRIPT_DIR" != "$SHARED_CONFIG_DIR" ]; then
  # Cloned elsewhere (e.g., ~/kickstart.nvim) -> copy into /opt/nvim-config
  echo "Copying local clone from ${SCRIPT_DIR} to ${SHARED_CONFIG_DIR}..."
  rm -rf "${SHARED_CONFIG_DIR}"
  cp -a "${SCRIPT_DIR}" "${SHARED_CONFIG_DIR}"
  git -C "${SHARED_CONFIG_DIR}" checkout "${BRANCH}"
elif [ -d "${SHARED_CONFIG_DIR}/.git" ]; then
  # Already cloned directly into /opt/nvim-config -> just ensure branch matches locally
  echo "Using existing repo in ${SHARED_CONFIG_DIR}..."
  CURRENT_BRANCH="$(git -C "${SHARED_CONFIG_DIR}" rev-parse --abbrev-ref HEAD)"
  if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
    git -C "${SHARED_CONFIG_DIR}" checkout "${BRANCH}"
  fi
else
  # Fallback if run outside any git clone
  echo "Cloning ${REPO_URL} (${BRANCH}) into ${SHARED_CONFIG_DIR}..."
  git clone --branch "${BRANCH}" "${REPO_URL}" "${SHARED_CONFIG_DIR}"
fi

# 3. Symlink ~/.config/nvim -> /opt/nvim-config for root and ssm-user
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
for USER_HOME in /root /home/ssm-user; do
  if [ -d "$USER_HOME" ]; then
    mkdir -p "${USER_HOME}/.config"
    TARGET_LINK="${USER_HOME}/.config/nvim"
    if [ -d "$TARGET_LINK" ] && [ ! -L "$TARGET_LINK" ]; then
      mv "$TARGET_LINK" "${TARGET_LINK}.bak_${TIMESTAMP}"
    fi
    ln -sfn "${SHARED_CONFIG_DIR}" "$TARGET_LINK"
  fi
done

# 4. Run finishInstallation.sh
chmod +x "${SHARED_CONFIG_DIR}/finishInstallation.sh"
"${SHARED_CONFIG_DIR}/finishInstallation.sh"

# 5. Replicate compiled plugin data (blink.cmp .so, lazy packages) to ssm-user
if id "ssm-user" >/dev/null 2>&1; then
  mkdir -p /home/ssm-user/.local/share
  rm -rf /home/ssm-user/.local/share/nvim
  cp -a /root/.local/share/nvim /home/ssm-user/.local/share/
  chown -R ssm-user:ssm-user "${SHARED_CONFIG_DIR}" /home/ssm-user/.config /home/ssm-user/.local
fi

echo "Setup complete: $(nvim --version | head -n 1) configured in ${SHARED_CONFIG_DIR}."
