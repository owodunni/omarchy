#!/bin/bash

# Create keyd configuration file
if [ ! -f /etc/keyd/default.conf ]; then
  cat <<EOF >/etc/keyd/default.conf
[ids]

*

[main]

# Maps capslock to backslash
capslock = backslash

[meta]

# Mac-like key bindings: Super + key -> Ctrl + key
c = C-c
v = C-v
a = C-a
z = C-z
x = C-x
f = C-f
EOF
fi

if ! groups $USER | grep -q keyd; then
  usermod -aG keyd $USER
  echo "Added $USER to keyd group."
fi

# Enable keyd if not already disabled
if ! systemctl is-enabled keyd | grep -q enabled; then
  systemctl enable keyd
fi
