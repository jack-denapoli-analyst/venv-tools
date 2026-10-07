#!/bin/bash
# setup-venv.sh - Create venv and install packages from config files

set -e  # Exit on any error

# Configuration
CONFIG_DIR="${HOME}/.venv-configs"
SCRIPT_NAME="$(basename "$0")"

# Display usage
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] <venv-name> [config-file]

Create a Python virtual environment and install packages.

Arguments:
  venv-name      Name of the virtual environment directory
  config-file    Config file basename (without .conf extension), or 'list' to show available configs

Options:
  -l, --list     List available configuration files
  -p, --packages PACKAGES  Space-separated list of packages (overrides config file)
  -h, --help     Show this help message

Examples:
  $SCRIPT_NAME data-project data-science
  $SCRIPT_NAME ml-workflow machine-learning
  $SCRIPT_NAME web-dev -p flask django requests
  $SCRIPT_NAME --list

Config files are stored in: $CONFIG_DIR

EOF
}

# Parse arguments
LIST_CONFIGS=false
CUSTOM_PACKAGES=""
VENV_NAME=""
CONFIG_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--list)
            LIST_CONFIGS=true
            shift
            ;;
        -p|--packages)
            CUSTOM_PACKAGES="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            if [ -z "$VENV_NAME" ]; then
                VENV_NAME="$1"
            else
                CONFIG_FILE="$1"
            fi
            shift
            ;;
    esac
done

# List available configs
if [ "$LIST_CONFIGS" = true ]; then
    echo "=== Available Configuration Files ==="
    echo "Located in: $CONFIG_DIR"
    echo ""
    ls -la "$CONFIG_DIR"/*.conf 2>/dev/null | awk '{print "  " $NF}' || echo "  No config files found."
    echo ""
    echo "Create new config: echo 'package1 package2' > $CONFIG_DIR/myconfig.conf"
    exit 0
fi

# Validate inputs
if [ -z "$VENV_NAME" ]; then
    echo "ERROR: Virtual environment name is required"
    echo "Usage: $SCRIPT_NAME <venv-name> [config-file]"
    exit 1
fi

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Load packages from config or use custom/packages argument
load_packages() {
    local config="$1"
    if [ -n "$CUSTOM_PACKAGES" ]; then
        echo "$CUSTOM_PACKAGES"
    elif [ -n "$config" ]; then
        local config_path="$CONFIG_DIR/${config}.conf"
        if [ ! -f "$config_path" ]; then
            echo "ERROR: Config file '$config_path' not found."
            echo "Available configs:"
            ls "$CONFIG_DIR"/*.conf 2>/dev/null | xargs -I{} basename {} .conf | sed 's/^/  /' || echo "  (none)"
            exit 1
        fi
        cat "$config_path" | tr '\n' ' ' | grep -v '^$' || echo ""
    else
        echo ""
    fi
}

PACKAGES=$(load_packages "$CONFIG_FILE")

# Display configuration summary
echo "=== Setting Up Python Virtual Environment ==="
echo "Environment name: $VENV_NAME"
if [ -n "$CONFIG_FILE" ]; then
    echo "Configuration: $(readlink -f "$CONFIG_DIR/$CONFIG_FILE.conf")"
else
    echo "Configuration: default (no config file specified)"
fi
echo "Packages: ${PACKAGES:-[none - empty environment]}"

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 not found. Install with 'sudo apt install python3-full'"
    exit 1
fi

# Handle existing venv
if [ -d "$VENV_NAME" ]; then
    echo "WARNING: '$VENV_NAME' already exists!"
    read -p "Recreate? (This will delete existing env) [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$VENV_NAME"
        echo "Removed existing environment."
    else
        echo "Aborted. Use a different name or delete manually."
        exit 0
    fi
fi

# Create the virtual environment
echo ""
echo "Creating virtual environment..."
python3 -m venv "$VENV_NAME"

# Upgrade pip inside the venv
echo "Upgrading pip..."
"$VENV_NAME"/bin/pip install --upgrade pip --quiet

# Install requested packages
if [ -n "$PACKAGES" ]; then
    echo "Installing packages..."
    "$VENV_NAME"/bin/pip install $PACKAGES --quiet
else
    echo "Skipping package installation (no packages specified)"
fi

echo ""
echo "=== Setup Complete ==="
echo "Activate: source $VENV_NAME/bin/activate"
echo "Deactivate: deactivate"
