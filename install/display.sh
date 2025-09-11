#!/bin/bash

# Create DisplayLink Xorg configuration
if [ ! -f /etc/X11/xorg.conf.d/20-evdi.conf ]; then
  cat <<EOF | sudo tee /etc/X11/xorg.conf.d/20-evdi.conf
Section "OutputClass"
  Identifier "DisplayLink"
  MatchDriver "evdi"
  Driver "modesetting"
  Option "AccelMethod" "none"
EndSection
EOF
fi

# Enable displaylink service
if ! systemctl is-enabled displaylink.service | grep -q enabled; then
  sudo systemctl enable displaylink.service
fi

# Start displaylink service if not running
if ! systemctl is-active displaylink.service | grep -q active; then
  sudo systemctl start displaylink.service
fi