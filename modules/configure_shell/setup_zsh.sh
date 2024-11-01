#!/usr/bin/env bash

sudo chsh -s $(which "zsh") $(whoami)

if [[ ! -d "$HOME/.oh-my-zsh/" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
fi

<<- 'EOF' | zsh -s
source $HOME/.zshrc
omz plugin enable ${OMZ_PLUGINS} || true
EOF
