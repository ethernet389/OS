#!/usr/bin/env bash

[[ "$PWD" = "$HOME" ]] && exit

echo "Error: current dir is not $HOME"
exit 1
