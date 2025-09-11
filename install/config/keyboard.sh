#!/bin/bash

# Create xremap config directory
mkdir -p ~/.config/xremap

# Create XRemap configuration file
if [ ! -f ~/.config/xremap/config.yml ]; then
  cat <<EOF >~/.config/xremap/config.yml
# XRemap configuration for Mac-like keyboard shortcuts
# Maps Ctrl+C/V/X/A to Super+C/V/X/A for most applications

keymap:
  - name: Mac-like shortcuts
    application:
      not: [Alacritty, alacritty, gnome-terminal, konsole, xterm, kitty, wezterm]
    remap:
      # Core Mac shortcuts using Super key
      Super-c: C-c  # Copy
      Super-v: C-v  # Paste
      Super-x: C-x  # Cut
      Super-a: C-a  # Select All

modmap:
  - name: Vim
    remap:
      CapsLock: \\
EOF
fi

#Set up udev rules for XRemap device access
if [ ! -f /etc/udev/rules.d/99-xremap.rules ]; then
  cat <<EOF | sudo tee /etc/udev/rules.d/99-xremap.rules
KERNEL=="uinput", GROUP="input", TAG+="uaccess"
KERNEL=="event*", GROUP="input", TAG+="uaccess"
EOF
fi

# Add user to input group for device access
if ! groups $USER | grep -q input; then
  sudo usermod -a -G input $USER
  echo "Added $USER to input group. You may need to log out and back in for this to take effect."
fi

# Create systemd user service for XRemap
mkdir -p ~/.config/systemd/user

if [ ! -f ~/.config/systemd/user/xremap.service ]; then
  cat <<EOF >~/.config/systemd/user/xremap.service
[Unit]
Description=Xremap
After=default.target

[Service]
ExecStart=/usr/bin/xremap --watch=device %h/.config/xremap/config.yml
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF
fi

# Enable power-profiles-daemon only if not already disabled
if ! systemctl --user is-enabled xremap.service | grep -q enabled; then
  systemctl --user enable xremap.service
fi
