#!/usr/bin/env bash

# Request administrative privileges upfront
if [ "$EUID" -ne 0 ]; then
  echo "Requesting administrative privileges..."
  sudo -v
  if [ $? -ne 0 ]; then
    echo "Administrative privileges denied."
    exit 1
  fi
  echo "Administrative privileges granted."
fi

# URL of your RCLI repository
REPO_URL="git@github.com:sec0ndhand/rcli.git"


# Determine custom command name
CUSTOM_NAME="${1:-rcli}"

INSTALL_DIR="$(pwd)/$CUSTOM_NAME"
RCLI_DIR="$INSTALL_DIR/rcli"
COMMAND_PATH="$RCLI_DIR/src/cli"

# create the install directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
fi

# Clone the RCLI repository
if git clone "$REPO_URL" "$RCLI_DIR"; then
    echo "RCLI has been successfully cloned to $RCLI_DIR"
else
    echo "Failed to clone RCLI from $REPO_URL"
    exit 1
fi

# copy the resources directory to the install directory
cp -r "$RCLI_DIR/src/resources" "$INSTALL_DIR"

# Grant execute permissions to the RCLI script
chmod +x "$COMMAND_PATH"

# Update the LAST_CHECKED.txt file with the current date
echo $(date +%Y-%m-%d) > "$RCLI_DIR/LAST_CHECKED"
echo "LAST_CHECKED has been updated with the current date."


# Save the chosen custom name to the NAME file
echo "$CUSTOM_NAME" > "$RCLI_DIR/NAME"

# Create a symlink using the custom name
sudo ln -s "$COMMAND_PATH" "/usr/local/bin/$CUSTOM_NAME"
echo "RCLI has been installed and can be accessed via the '$CUSTOM_NAME' command"
