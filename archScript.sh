#!/bin/bash
# Stop execution if any command fails
set -e

# Set variables for the drives and partitions
 DISK="/dev/sdb"                # The SSD where Arch will be installed
 EFI_PARTITION="${DISK}1"        # EFI partition
 ROOT_PARTITION="${DISK}2"       # Root partition

# Update the system clock
 timedatectl set-ntp true

# Partition the disk (adjust partition sizes as needed)
 parted $DISK mklabel gpt
 parted $DISK mkpart primary fat32 1MiB 513MiB
 parted $DISK set 1 esp on
 parted $DISK mkpart primary ext4 513MiB 100%

# Format the partitions
 mkfs.fat -F32 $EFI_PARTITION
 mkfs.ext4 $ROOT_PARTITION

# Mount the partitions
 mount $ROOT_PARTITION /mnt
 mkdir -p /mnt/boot/efi
 mount $EFI_PARTITION /mnt/boot/efi

# Install essential packages
 pacstrap /mnt base linux linux-firmware vim

# Generate the filesystem table (fstab)
 genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
 arch-chroot /mnt /bin/bash <<EOF

# Set the time zone
 ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
 hwclock --systohc

# Set up locales
 echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
 locale-gen
 echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set up hostname and hosts file
 echo "archlinux" > /etc/hostname
 cat <<HOSTS > /etc/hosts
 127.0.0.1   localhost
 ::1         localhost
 127.0.1.1   archlinux.localdomain archlinux
 HOSTS

# Set root password
 echo "Set root password:"
 passwd

# Install necessary packages
 pacman -S --noconfirm grub efibootmgr networkmanager sudo nvidia nvidia-utils nvidia-settings

# Set up the GRUB bootloader
 grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
 grub-mkconfig -o /boot/grub/grub.cfg

# Enable NetworkManager for network connectivity
 systemctl enable NetworkManager

# Create a user account with sudo privileges
 echo "Create a new user:"
 read -p "Username: " username
 useradd -m -G wheel $username
 passwd $username

# Give the user sudo privileges
 sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

 EOF

# Unmount partitions and reboot
 umount -R /mnt
 echo "Arch Linux installation is complete. Rebooting now."
 reboot

