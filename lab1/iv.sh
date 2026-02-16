#!/usr/bin/env bash

if [[ "$PWD" = "$HOME" ]]; then
  echo "$PWD"
  exit
fi

echo "Error: current dir is not $HOME"
exit 1
