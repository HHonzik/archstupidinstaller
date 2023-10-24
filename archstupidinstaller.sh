#!/bin/bash

read -p "This script will fuck up your disk and install Arch Linux. Do you want to continue (you will need to be watching the install beacuse a lot of stuff will need to be manual after waiting)? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "Installation aborted."
    exit 1
fi

# Display available disks and ask the user to select one
fdisk -l
read -p "Enter the disk to fuck (e.g., /dev/sda): " selected_disk

# Clear the selected disk
dd if=/dev/zero of=$selected_disk bs=512 count=1

# Prompt for swap size or skip
read -p "Enter the fucking swap size (e.g., +2G or press Enter to skip): " swap_size

# Create partitions
(
  echo o      # Create a new empty DOS partition table
  if [ -n "$swap_size" ]; then
    echo n     # Add a new partition
    echo        # Default partition number (1)
    echo        # Default first sector
    echo $swap_size  # Use specified swap size
  fi
  echo n      # Add a new partition
  echo        # Default partition number (2)
  echo        # Default first sector
  echo        # Default last sector (use the rest of the disk)
  echo a      # Make a partition bootable
  echo 2      # Select the second partition for booting
  echo w      # Write changes
) | fdisk $selected_disk

# Format partitions
if [ -n "$swap_size" ]; then
  mkswap ${selected_disk}1
  swapon ${selected_disk}1
  mkfs.ext4 ${selected_disk}2
else
  mkfs.ext4 ${selected_disk}1
fi

# Mount root partition
mount ${selected_disk}2 /mnt

# Install essential packages (NEOFETCH TO FLEX)
pacstrap -i /mnt base linux linux-firmware nano sudo iwd dhcpcd openssh wget grub neofetch git

# Generate the fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Change root into the new system
arch-chroot /mnt <<EOF

# Set system time and timezone (user interaction required)
read -p "Enter your fucking timezone (e.g., America/New_York): " timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

# Configure locales (user interaction required)
nano /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Set the keyboard layout (user interaction required)
read -p "Enter your fucked KEYBOARD LAYOUT (e.g., us, cz-qwertz): " keymap
echo "KEYMAP=$keymap" >> /etc/vconsole.conf

# Set the hostname (user interaction required)
read -p "Enter the fuckname: " hostname
echo "$hostname" > /etc/hostname

# Generate initramfs
mkinitcpio -P

# Set the root password
passwd

# Install GRUB (using the previously selected disk)
grub-install $selected_disk

# Generate GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg

EOF

read -p "Do you want to fuck strait into the Arch Linux install (remove the disk after the screen with OK and things on the black screen) (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "Ok, your in the fucking terminal now, write reboot to reboot into the installed enviroment (LOGIC)."
    exit 1
fi

# Reboot the system
reboot
