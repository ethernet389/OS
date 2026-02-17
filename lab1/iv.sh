#!/usr/bin/env bash

if [[ "$PWD" = "$HOME" ]]; then
  echo "$HOME"
else
  echo "Error: current dir is not $HOME"
  exit 1
fi
