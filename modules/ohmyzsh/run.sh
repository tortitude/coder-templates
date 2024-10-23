%{if SET_PREFERRED_SHELL ~}
sudo chsh -s $(which "zsh") $(whoami)
%{endif ~}

if [[ ! -d "$HOME/.oh-my-zsh/" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
fi

%{ for plugin_name in OMZ_PLUGINS ~}
zsh -c 'source .zshrc && omz plugin enable "${plugin_name}"'
%{ endfor ~}
