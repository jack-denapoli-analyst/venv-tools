#!/bin/bash
# bootstrap.sh - One-command setup for venv automation
# Run: bash bootstrap.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="venv-tools"

echo "=== Venv Tools Bootstrap ==="
echo "Installing in: $SCRIPT_DIR"

# --- 1. Ensure scripts are executable ---
echo "[1/5] Setting up executable permissions..."
chmod +x "$SCRIPT_DIR/setup-venv.sh"
chmod +x "$SCRIPT_DIR/bootstrap.sh"

# --- 2. Set up config directory symlink ---
echo "[2/5] Linking configuration directory..."
CONFIG_LINK="$HOME/.venv-configs"
if [ -L "$CONFIG_LINK" ]; then
    echo "  ✓ Config link already exists"
elif [ -d "$CONFIG_LINK" ]; then
    echo "  ⚠ Existing directory found at $CONFIG_LINK"
    read -p "  Overwrite with symlink to project configs? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$CONFIG_LINK"
        ln -s "$SCRIPT_DIR/configs" "$CONFIG_LINK"
        echo "  ✓ Symlink created"
    else
        echo "  ℹ Keeping existing configs (scripts will use local ones)"
    fi
else
    ln -s "$SCRIPT_DIR/configs" "$CONFIG_LINK"
    echo "  ✓ Created symlink at $CONFIG_LINK"
fi

# --- 3. Add aliases to shell config ---
echo "[3/5] Setting up shell aliases..."
SHELL_CONFIG="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ] && [ -n "${ZSH_VERSION:-}" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
fi

ALIAS_BLOCK="# === Venv Tools Aliases ==="

# Check if aliases already exist
if grep -q "$ALIAS_BLOCK" "$SHELL_CONFIG" 2>/dev/null; then
    echo "  ✓ Aliases already configured"
else
    cat >> "$SHELL_CONFIG" << 'ALIASES'

# === Venv Tools Aliases ===
alias venv-setup='~/venv-tools/setup-venv.sh'
alias venv-list='~/venv-tools/setup-venv.sh --list'
alias venv-active='source "$(pwd)/bin/activate"'
ALIASES
    echo "  ✓ Added aliases to $SHELL_CONFIG"
fi

# --- 4. Reload shell config ---
echo "[4/5] Reloading shell configuration..."
if [ -f "$SHELL_CONFIG" ]; then
    source "$SHELL_CONFIG"
    echo "  ✓ Shell config reloaded"
fi

# --- 5. Verification ---
echo "[5/5] Running verification..."
if command -v python3 &> /dev/null; then
    PYTHON_VER=$(python3 --version | awk '{print $2}')
    echo "  ✓ Python $PYTHON_VER detected"
else
    echo "  ⚠ Warning: Python 3 not found in PATH"
fi

if command -v pip3 &> /dev/null; then
    echo "  ✓ pip3 available"
else
    echo "  ⚠ Warning: pip3 not found in PATH"
fi

# --- Final Summary ---
echo ""
echo "=== Bootstrap Complete ==="
echo ""
echo "Quick Start Commands:"
echo "  venv-list                    # Show all config profiles"
echo "  venv-setup myproject data-science"
echo "  source myproject/bin/activate"
echo ""
echo "Documentation: $SCRIPT_DIR/README.md"
echo ""
