#!/usr/bin/env bash

# URL of your RCLI repository
REPO_URL="https://github.com/your-username/RCLI-repo.git"
INSTALL_DIR="$HOME/rcli"

# Clone the RCLI repository
if git clone "$REPO_URL" "$INSTALL_DIR"; then
    echo "RCLI has been successfully cloned to $INSTALL_DIR"
else
    echo "Failed to clone RCLI from $REPO_URL"
    exit 1
fi

# Grant execute permissions to the RCLI script
chmod +x "$INSTALL_DIR/RCLI"

# Update the LAST_CHECKED.txt file with the current date
echo $(date +%Y-%m-%d) > "$INSTALL_DIR/LAST_CHECKED.txt"
echo "LAST_CHECKED.txt has been updated with the current date."

# Determine custom command name
if [[ -n "$1" ]]; then
    # If name is provided as first parameter, use it
    CUSTOM_NAME="$1"
elif [[ -f "$INSTALL_DIR/NAME" ]]; then
    # If NAME file exists, read the custom name from it
    CUSTOM_NAME=$(cat "$INSTALL_DIR/NAME")
else
    # Default to "rcli" if no other name is provided
    CUSTOM_NAME="rcli"
fi

# Save the chosen custom name to the NAME file
echo "$CUSTOM_NAME" > "$INSTALL_DIR/NAME"

# Create a symlink using the custom name
ln -s "$INSTALL_DIR/RCLI" "/usr/local/bin/$CUSTOM_NAME"
echo "RCLI has been installed and can be accessed via the '$CUSTOM_NAME' command"
