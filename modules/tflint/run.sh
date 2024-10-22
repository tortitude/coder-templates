#!/usr/bin/env bash

if [ "$TFLINT_INSTALLER_CLEAR_GH_TOKEN" == '1' ]; then
    echo 'Clearing GH_TOKEN before install...'
    unset GH_TOKEN
fi

echo "GHT: $GH_TOKEN"

if command -v "${TFLINT_INSTALLER_SKIP_IF_COMMAND_EXISTS}" &> /dev/null; then
    if [ "$TFLINT_INSTALLER_FORCE_INSTALL" != '1' ]; then
        echo 'Skipping tflint installation (already installed)'
        exit 0
    fi
    echo "Command $TFLINT_INSTALLER_SKIP_IF_COMMAND_EXISTS exists."
    echo "Attempting to re-install as requested..."
fi

echo 'Downloading tflint install script...'
install_script="$(curl -sS -o- 'https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh' 2>&1)"
if [ $? -ne 0 ]; then
  echo "Failed to download tflint installation script: $install_script"
  exit 1
fi

echo 'Running tflint installer...'
output="$(bash <<< "$install_script" 2>&1)"
if [ $? -ne 0 ]; then
  echo "Failed to install tflint: $output"
  exit 1
fi

echo 'tflint is now installed!'
