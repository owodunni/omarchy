# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Omarchy is an Arch Linux system configuration tool that transforms a fresh installation into a fully-configured Hyprland-based development environment. The system is modular with shell scripts organized into functional categories.

## Architecture

- **Entry Points**: 
  - `boot.sh` - Downloads and initializes Omarchy from GitHub
  - `install.sh` - Main installation orchestrator that sources all installation modules
- **Directory Structure**:
  - `install/` - Installation modules organized by phase (preflight, packaging, config, login, power)
  - `config/` - Configuration files for various applications (nvim, hyprland, waybar, etc.)
  - `bin/` - Custom Omarchy commands and utilities (70+ scripts prefixed with `omarchy-`)
  - `migrations/` - System migration scripts with timestamps
  - `themes/` - Theme definitions and assets
  - `applications/` - Desktop application definitions
  - `default/` - Default configuration templates

## Core Commands

### Installation
```bash
# Full system installation (run from fresh Arch install)
bash <(curl -s https://omarchy.org/boot.sh)

# Re-run installation from existing clone
~/.local/share/omarchy/install.sh
```

### Package Management
```bash
omarchy-pkg-install <package>    # Install package via pacman/yay
omarchy-pkg-remove <package>     # Remove package
omarchy-pkg-aur-install <pkg>    # Install AUR package specifically
omarchy-pkg-missing              # List missing packages
```

### System Updates
```bash
omarchy-update                   # Update Omarchy itself
omarchy-update-system-pkgs       # Update system packages
omarchy-migrate                  # Run pending migrations
```

### Configuration Management
```bash
omarchy-refresh-config           # Refresh all configs
omarchy-refresh-hyprland         # Restart Hyprland
omarchy-refresh-waybar           # Restart waybar
omarchy-theme-set <theme>        # Set theme
omarchy-theme-list               # List available themes
```

## Development Environment

The system installs comprehensive development tools:
- **Languages**: Rust (cargo), Python (mise), Ruby (mise), Node.js
- **Editors**: Neovim with LazyVim configuration
- **Containers**: Docker with docker-compose
- **CLI Tools**: lazygit, lazydocker, fzf, ripgrep, bat, eza, btop
- **Version Control**: git, github-cli

## Installation Flow

1. **Preflight**: Environment checks, error handling, pacman setup, migrations
2. **Packaging**: Core packages, fonts, LazyVim, webapps, TUIs
3. **Configuration**: System configs, themes, hardware-specific tweaks
4. **Login**: Plymouth, bootloader configuration
5. **Power**: Power management setup
6. **Finishing**: System reboot

## Key Features

- **Modular Architecture**: Each installation phase is in separate scripts
- **Hardware Detection**: Automatic configuration for different hardware (network, bluetooth, etc.)
- **Migration System**: Timestamped migrations for system updates
- **Theme Management**: Complete theming system with background/color schemes
- **Custom Utilities**: 70+ `omarchy-*` commands for system management
- **Package Pinning**: Mechanism to pin specific package versions

## Configuration Files

Key configuration locations:
- Hyprland: `config/hyprland/`
- Waybar: `config/waybar/`
- Neovim: `config/nvim/` (LazyVim setup)
- Terminal: Uses Alacritty as default

## Testing Changes

After making changes to installation scripts:
```bash
# Test specific installation phase
source install/config/git.sh

# Run migrations
omarchy-migrate

# Refresh configurations
omarchy-refresh-config
```