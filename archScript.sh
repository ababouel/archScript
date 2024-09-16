#!/bin/bash
# Stop execution if any command fails
set -e

# Set variables for the drives and partitions
 echo "Set variables\n"
 DISK="/dev/sdb"                # The SSD where Arch will be installed
 EFI_PARTITION="${DISK}1"        # EFI partition
 ROOT_PARTITION="${DISK}2"       # Root partition

# Update the system clock
 echo "Update the system clock\n"
 timedatectl set-ntp true

# Partition the disk (adjust partition sizes as needed)
 echo "Partition the disk\n"
 parted $DISK mklabel gpt
 parted $DISK mkpart primary fat32 1MiB 513MiB
 parted $DISK set 1 esp on
 parted $DISK mkpart primary ext4 513MiB 100%

# Format the partitions
 echo "Format the partitions \n"
 mkfs.fat -F32 $EFI_PARTITION
 mkfs.ext4 $ROOT_PARTITION

# Mount the partitions
 echo "Mount the partitions\n"
 mount $ROOT_PARTITION /mnt
 mkdir -p /mnt/boot/efi
 mount $EFI_PARTITION /mnt/boot/efi

# Install essential packages
 echo "Install packages \n"
 pacstrap /mnt base linux linux-firmware vim

# Generate the filesystem table (fstab)
 echo "Generate the fileSystem \n"
 genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
 echo "Chroot into the new system \n"
 arch-chroot /mnt /bin/bash <<EOF

# Set the time zone
 echo "Set the time zone\n"
 ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
 hwclock --systohc

# Set up locales
 echo "Set up locales\n"
 echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
 locale-gen
 echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set up hostname and hosts file
 echo "Set up hostname\n"
 echo "127.0.0.1   localhost" > /etc/hosts
 echo "::1         localhost" >> /etc/hosts
 echo "127.0.1.1   archlinux.localdomain archlinux" >> /etc/hostscho "archlinux" > /etc/hostname

# Set root password
 echo "Set root password:"
 passwd

# Install necessary packages
 echo "Install necessary packages\n"
 pacman -S --noconfirm grub efibootmgr networkmanager sudo nvidia nvidia-utils nvidia-settings

# Set up the GRUB bootloader
 echo "Set up the Grub\n"
 grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
 grub-mkconfig -o /boot/grub/grub.cfg

# Enable NetworkManager for network connectivity
 echo "enabling NetworkManager\n"
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

