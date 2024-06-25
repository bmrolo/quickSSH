#!/bin/bash
REPO_URL="https://github.com/bmrolo/quickSSH.git"
SCRIPT_NAME="quickssh.sh"
INSTALL_PATH="/usr/local/bin/quickssh"

# Clone the repository silently
if ! git clone "$REPO_URL"; then
    echo "Failed to clone repository."
    exit 1
fi

cd quickSSH || { echo "Failed to enter directory."; exit 1; }

# Make the script executable
chmod +x "$SCRIPT_NAME"

# Move the script to /usr/local/bin
if ! sudo cp "$SCRIPT_NAME" "$INSTALL_PATH"; then
    echo "Failed to copy script to $INSTALL_PATH."
    exit 1
fi

# Clean up
cd ..
rm -rf quickSSH

echo "Installation complete. You can now use the 'quickssh' command."
