#!/usr/bin/env bash

sudo chsh -s $(which "zsh") $(whoami)

if [[ ! -d "$HOME/.oh-my-zsh/" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
fi

%{ for plugin_name in OMZ_PLUGINS ~}
<<- 'EOF' | zsh -s
source $HOME/.zshrc
echo $plugins | grep -E '(^|\s)${plugin_name}(\s|$)' > /dev/null || omz plugin enable ${plugin_name}
EOF
%{ endfor ~}
