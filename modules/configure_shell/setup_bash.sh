#!/usr/bin/env bash

sudo chsh -s $(which "bash") $(whoami)

if [[ ! -f "$HOME/.bash_profile" ]]; then
  echo 'source /etc/profile.d/bash_completion.sh' >> "$HOME/.bash_profile"
  echo 'source "$HOME/.coder_bash_completions"' >> "$HOME/.bash_profile"
  echo 'source "$HOME/.bash_profile"' >> "$HOME/.bashrc"
fi

CODER_COMPLETIONS_FILE="$HOME/.coder_bash_completions"

echo '' > "$CODER_COMPLETIONS_FILE"
%{ for c_path__name in BASH_COMPLETIONS ~}
echo "complete -C \"${c_path__name[0]}\" \"${c_path__name[1]}\"" >> "$CODER_COMPLETIONS_FILE"
%{ endfor ~}
