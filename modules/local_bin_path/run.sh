#!/usr/bin/env bash

mkdir -p "$HOME/${LOCAL_BIN_DIR}"

if ! grep -qxF 'export PATH=$PATH:$HOME/.local/bin' "$HOME/${RCFILE}" ; then
  echo "Appending $HOME/${LOCAL_BIN_DIR} to path in $HOME/${RCFILE} ..."
  echo 'export PATH=$PATH:$HOME/${LOCAL_BIN_DIR}' >> "$HOME/${RCFILE}"
fi

if [[ "$PATH" != *"$HOME/${LOCAL_BIN_DIR}"* ]]; then
  export PATH=$PATH:$HOME/${LOCAL_BIN_DIR}
fi

%{ for command in ENSURE_SYMLINKS ~}
link_source="$(which ${command.source})"
link_target="$HOME/${LOCAL_BIN_DIR}/${command.target}"
if ! command -v ${command.target} > /dev/null; then
    if [[ ! -f "$link_target" ]]; then
        echo "Linking $link_source to $link_target ..."
        ln -s $link_source $link_target
    fi
fi
%{ endfor ~}
