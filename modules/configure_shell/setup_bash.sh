#!/usr/bin/env bash

sudo chsh -s $(which "bash") $(whoami)

if [[ ! -f "$HOME/.bash_profile" ]]; then
  echo 'source /etc/profile.d/bash_completion.sh' >> "$HOME/.bash_profile"
  echo 'source "$HOME/.coder_bash_completions"' >> "$HOME/.bash_profile"
  echo 'source "$HOME/.bash_profile"' >> "$HOME/.bashrc"
fi

CODER_COMPLETIONS_FILE="$HOME/.coder_bash_completions"

echo '' > "$CODER_COMPLETIONS_FILE"
%{ for comp in BASH_COMPLETIONS ~}
echo "complete -C \"${comp.path}\" ${comp.name}" >> "$CODER_COMPLETIONS_FILE"
%{ endfor ~}
