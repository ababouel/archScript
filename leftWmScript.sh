#!/bin/bash

# LeftWM and NVIDIA Installation Script for Arch Linux with Ly

# Ensure the script is run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update the system
echo "Updating the system..."
pacman -Syu --noconfirm

# Install required packages
echo "Installing required packages..."
pacman -S --noconfirm \
    xorg xorg-server xorg-xinit \
    leftwm \
    alacritty \
    nvidia nvidia-utils nvidia-settings \
    base-devel git \
    feh picom \
    dmenu \
    network-manager-applet \
    pulseaudio pavucontrol \
    firefox \
    thunar

# Enable and start NetworkManager
systemctl enable NetworkManager
systemctl start NetworkManager

# Create LeftWM config directory
mkdir -p /etc/X11/xinit/xinitrc.d

# Create a xinitrc file for LeftWM
cat > /etc/X11/xinit/xinitrc.d/50-systemd-user.sh << EOF
#!/bin/sh

systemctl --user import-environment DISPLAY XAUTHORITY

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment DISPLAY XAUTHORITY
fi
EOF

chmod +x /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

# Configure NVIDIA
echo "Configuring NVIDIA..."
nvidia-xconfig

# Install yay (AUR helper)
echo "Installing yay..."
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# Install Ly display manager from AUR
echo "Installing Ly display manager..."
yay -S --noconfirm ly

# Enable Ly
systemctl enable ly.service

# Install additional LeftWM themes (optional)
echo "Installing LeftWM themes..."
yay -S --noconfirm leftwm-theme-git

# Create a basic LeftWM config
mkdir -p /etc/leftwm
cat > /etc/leftwm/config.toml << EOF
modkey = "Mod4"
workspaces = []
tags = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

[[keybind]]
command = "Execute"
value = "alacritty"
modifier = ["modkey"]
key = "Return"

[[keybind]]
command = "Execute"
value = "dmenu_run"
modifier = ["modkey"]
key = "p"

[[keybind]]
command = "CloseWindow"
modifier = ["modkey", "Shift"]
key = "q"

[[keybind]]
command = "SoftReload"
modifier = ["modkey", "Shift"]
key = "r"

[[keybind]]
command = "Execute"
value = "loginctl kill-session $XDG_SESSION_ID"
modifier = ["modkey", "Shift"]
key = "x"

[[keybind]]
command = "MoveWindowToLastWorkspace"
modifier = ["modkey", "Shift"]
key = "w"

[[keybind]]
command = "SwapTags"
modifier = ["modkey"]
key = "w"

[[keybind]]
command = "MoveWindowUp"
modifier = ["modkey", "Shift"]
key = "k"

[[keybind]]
command = "MoveWindowDown"
modifier = ["modkey", "Shift"]
key = "j"

[[keybind]]
command = "FocusWindowUp"
modifier = ["modkey"]
key = "k"

[[keybind]]
command = "FocusWindowDown"
modifier = ["modkey"]
key = "j"

[[keybind]]
command = "NextLayout"
modifier = ["modkey", "Control"]
key = "k"

[[keybind]]
command = "PreviousLayout"
modifier = ["modkey", "Control"]
key = "j"

[[keybind]]
command = "FocusWorkspaceNext"
modifier = ["modkey"]
key = "l"

[[keybind]]
command = "FocusWorkspacePrevious"
modifier = ["modkey"]
key = "h"

[[keybind]]
command = "GotoTag"
value = "1"
modifier = ["modkey"]
key = "1"

[[keybind]]
command = "GotoTag"
value = "2"
modifier = ["modkey"]
key = "2"

[[keybind]]
command = "GotoTag"
value = "3"
modifier = ["modkey"]
key = "3"

[[keybind]]
command = "GotoTag"
value = "4"
modifier = ["modkey"]
key = "4"

[[keybind]]
command = "GotoTag"
value = "5"
modifier = ["modkey"]
key = "5"

[[keybind]]
command = "GotoTag"
value = "6"
modifier = ["modkey"]
key = "6"

[[keybind]]
command = "GotoTag"
value = "7"
modifier = ["modkey"]
key = "7"

[[keybind]]
command = "GotoTag"
value = "8"
modifier = ["modkey"]
key = "8"

[[keybind]]
command = "GotoTag"
value = "9"
modifier = ["modkey"]
key = "9"

[[keybind]]
command = "MoveToTag"
value = "1"
modifier = ["modkey", "Shift"]
key = "1"

[[keybind]]
command = "MoveToTag"
value = "2"
modifier = ["modkey", "Shift"]
key = "2"

[[keybind]]
command = "MoveToTag"
value = "3"
modifier = ["modkey", "Shift"]
key = "3"

[[keybind]]
command = "MoveToTag"
value = "4"
modifier = ["modkey", "Shift"]
key = "4"

[[keybind]]
command = "MoveToTag"
value = "5"
modifier = ["modkey", "Shift"]
key = "5"

[[keybind]]
command = "MoveToTag"
value = "6"
modifier = ["modkey", "Shift"]
key = "6"

[[keybind]]
command = "MoveToTag"
value = "7"
modifier = ["modkey", "Shift"]
key = "7"

[[keybind]]
command = "MoveToTag"
value = "8"
modifier = ["modkey", "Shift"]
key = "8"

[[keybind]]
command = "MoveToTag"
value = "9"
modifier = ["modkey", "Shift"]
key = "9"
EOF

echo "Installation complete. Please reboot your system."
