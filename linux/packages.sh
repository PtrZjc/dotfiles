#!/bin/bash
# Robust Ubuntu/Debian Setup Script
# Strictly handles errors, detects architecture, and manages modern package constraints (PEP 668).

set -euo pipefail

# --- Configuration ---
LOG_FILE="${HOME}/install_log_$(date +%Y%m%d_%H%M%S).txt"
TEMP_DIR=$(mktemp -d)
ARCH=$(dpkg --print-architecture)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Helpers ---
log() { echo -e "${GREEN}[INFO]${NC} $1"; echo "[INFO] $1" >> "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; echo "[WARN] $1" >> "$LOG_FILE"; }
err()  { echo -e "${RED}[ERR]${NC} $1"; echo "[ERR] $1" >> "$LOG_FILE"; exit 1; }

cleanup() {
    rm -rf "$TEMP_DIR"
    # Kill the sudo keep-alive background job
    if [ -n "${SUDO_PID:-}" ]; then kill "$SUDO_PID" 2>/dev/null || true; fi
}
trap cleanup EXIT INT TERM

# Refresh sudo credentials and keep alive
sudo -v
(while true; do sudo -v; sleep 60; done) &
SUDO_PID=$!

# --- Architecture Check ---
if [[ "$ARCH" != "amd64" && "$ARCH" != "arm64" ]]; then
    warn "Detected architecture: $ARCH. Some binary downloads might fail if upstream does not provide pre-builts."
fi

log "Starting installation. Logs: $LOG_FILE"
log "System Architecture: $ARCH"

# --- 1. Core APT Packages ---
log "Updating apt repositories..."
export DEBIAN_FRONTEND=noninteractive
sudo apt update -q

PACKAGES=(
    # Core
    zsh neovim curl wget git unzip zip
    # Shell
    fzf ripgrep jq bat
    # Dev
    shellcheck gh libpq-dev build-essential
    # Python helpers (pipx is critical for modern Ubuntu)
    python3-pip python3-venv pipx
    # Data/Image
    miller gnuplot tesseract-ocr tesseract-ocr-eng tesseract-ocr-pol imagemagick
    # Misc
    qrencode pandoc texlive-latex-base texlive-fonts-recommended
    # Monitoring & Clipboard
    btop xclip wl-clipboard
)

log "Installing APT packages..."
# Filter out already installed packages to speed up apt
TO_INSTALL=()
for pkg in "${PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        TO_INSTALL+=("$pkg")
    fi
done

if [ ${#TO_INSTALL[@]} -gt 0 ]; then
    sudo apt install -y "${TO_INSTALL[@]}"
else
    log "All core apt packages already installed."
fi

# Ensure pipx path
if ! echo "$PATH" | grep -q "/.local/bin"; then
    warn "Ensure ~/.local/bin is in your PATH."
    export PATH="$HOME/.local/bin:$PATH"
fi
pipx ensurepath --force >/dev/null 2>&1 || true

# --- 2. Shell Compatibility Symlinks ---
mkdir -p "$HOME/.local/bin"

# fd-find
if ! command -v fd &>/dev/null; then
    if command -v fdfind &>/dev/null; then
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        log "Symlinked fdfind -> fd"
    else
        # Install fd-find explicitly if missed above or named differently
        sudo apt install -y fd-find
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    fi
fi

# bat (Ubuntu names it batcat)
if ! command -v bat &>/dev/null && command -v batcat &>/dev/null; then
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    log "Symlinked batcat -> bat"
fi

# --- 3. Third-Party Repositories (Eza) ---
if ! command -v eza &>/dev/null; then
    log "Installing eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg --yes
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo apt update -q && sudo apt install -y eza
fi

# --- 4. Binary Installs (GitHub Releases) ---

# Helper for GitHub releases
install_github_deb() {
    local repo="$1"
    local name="$2"
    local grep_pattern="$3"
    
    if command -v "$name" &>/dev/null; then
        log "$name already installed."
        return
    fi
    
    log "Installing $name from GitHub ($repo)..."
    
    # Get latest release tag
    local latest_url
    latest_url=$(curl -Ls -o /dev/null -w %{url_effective} "https://github.com/${repo}/releases/latest")
    local tag="${latest_url##*/}"
    
    # Construct download URL (Robust method: verify URL exists first or parse API)
    # Using API to find asset avoids guessing version string formats (v0.1 vs 0.1)
    local asset_url
    asset_url=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" | \
        grep "browser_download_url" | \
        grep -i "$grep_pattern" | \
        grep -i "$ARCH" | \
        head -n 1 | \
        cut -d '"' -f 4)

    if [ -z "$asset_url" ]; then
        warn "Could not find $name asset for $ARCH via API. Attempting fallback or skipping."
        return
    fi

    local deb_file="$TEMP_DIR/$name.deb"
    wget -qO "$deb_file" "$asset_url"
    sudo dpkg -i "$deb_file"
}

# # Bat (If not via apt/batcat) - Only if not symlinked/installed
# if ! command -v bat &>/dev/null; then
#     install_github_deb "sharkdp/bat" "bat" "musl" # musl builds are usually statically linked/safer
# fi

# Delta
install_github_deb "dandavison/delta" "git-delta" "git-delta_.*_$ARCH.deb"

# sd (sed replacement) - Binary preferred over cargo for speed
if ! command -v sd &>/dev/null; then
    log "Installing sd..."
    # sd doesn't always provide debs, use tarball strategy
    SD_VER=$(curl -s "https://api.github.com/repos/chmln/sd/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    # Determine target based on ARCH
    if [ "$ARCH" == "amd64" ]; then TARGET="x86_64-unknown-linux-musl"; 
    elif [ "$ARCH" == "arm64" ]; then TARGET="aarch64-unknown-linux-musl"; fi
    
    if [ -n "${TARGET:-}" ]; then
        wget -qO "$TEMP_DIR/sd.tar.gz" "https://github.com/chmln/sd/releases/download/${SD_VER}/sd-${SD_VER}-${TARGET}.tar.gz"
        tar -xzf "$TEMP_DIR/sd.tar.gz" -C "$TEMP_DIR"
        # Find binary inside extracted dir
        find "$TEMP_DIR" -name "sd" -type f -exec install -m 755 {} "$HOME/.local/bin/sd" \;
        log "sd installed to ~/.local/bin"
    else
        warn "sd build not found for architecture $ARCH"
    fi
fi

# Zoxide
if ! command -v zoxide &>/dev/null; then
    log "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# --- 5. Language Version Managers ---

# NVM
if [ ! -d "$HOME/.nvm" ]; then
    log "Installing NVM..."
    # Fetch latest version dynamically
    NVM_VER=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VER}/install.sh" | bash
else
    log "NVM already installed."
fi

# SDKMAN
if [ ! -d "$HOME/.sdkman" ]; then
    log "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
else
    log "SDKMAN already installed."
fi

# Pyenv
if [ ! -d "$HOME/.pyenv" ]; then
    log "Installing pyenv..."
    # Deps already installed in step 1
    curl https://pyenv.run | bash
else
    log "pyenv already installed."
fi

# --- 6. Python Tools (via pipx) ---
# Modern Ubuntu blocks raw 'pip install --user'. pipx is the standard fix.

install_pipx_tool() {
    local tool="$1"
    if ! pipx list | grep -q "$tool "; then
        log "Installing $tool via pipx..."
        pipx install "$tool"
    else
        log "$tool already installed via pipx."
    fi
}

install_pipx_tool "tldr"
install_pipx_tool "yq"

# --- 7. Final Checks ---

log "Installation complete."
echo ""
echo "=== Manual Action Required ==="
echo "1. Restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
echo "2. Add the following to your shell config if not present:"
echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "   eval \"\$(zoxide init zsh)\"  # or bash"
echo "   [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh"
echo ""

exit 0