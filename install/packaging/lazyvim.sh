#!/bin/bash

if [[ ! -d "$HOME/.config/nvim" ]]; then
  git clone https://github.com/owodunni/lazyvim ~/.config/nvim
fi
