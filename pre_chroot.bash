#!/usr/bin/env bash

# color variables
green="\033[0;32m"
red="\033[0;31m"
end="\033[0m"

CURRENTDIR=$(pwd)

# Get all drives
DRIVES=$(lsblk -l -n -p -d -o NAME,SIZE)

# Holds all drives
drives=()
drive_index=1

IFS="
"
for drive in $DRIVES; do
    # Extract drive id
    driveid=$(printf "${drive}" | awk '{print $1}')

    # Append drive id to array
    drives+=($driveid)

    # Print for user
    printf "[${drive_index}] ${drive}\n"

    # Increment drive index for user
    drive_index=$((drive_index+1))
done
unset IFS



# Ask user which drive to use
printf "Which drive would you like to use? "
read user_choice

# Check input is valid
while [[ ! $user_choice =~ ^[0-9]+$ ]] || [[ ! $((user_choice-1)) < ${#drives[@]} ]] || (( $((user_choice-1)) < 0 )); do
    printf "${red}Not valid, enter valid index: ${end}"
    read user_choice
done

# Save the root drive
root_drive=${drives[$((user_choice-1))]}

# Asking for confirmation
printf "Going to format ${green}${root_drive}${end}\n"
printf "Press ${green}ENTER${end} to continue\n"
read cont

# TODO: Uncomment this

# Create a GPT Partition table
#parted -s /dev/<device_name> mklabel gpt

# Create the boot partition
#parted -s /dev/<device_name> mkpart primary fat32 1MiB 2048MiB

# Create the OS partition
#parted -s /dev/<device_name> mkpart primary 2048MiB 100%

# Set the boot flags for the boot partition
#parted -s /dev/<device_name> set 1 esp on


# Get all partitions
parts=()
for part in $(lsblk /dev/nvme0n1 -p -l -o NAME,TYPE | awk '$2=="part"{print $1}'); do
    parts+=($part)
done

# Define partitons
efi_part=${parts[0]}
luks_part=${parts[1]}

# Get confirmation
printf "Your Boot partition is ${green}${efi_part}${end}\n"
printf "Your LUKS partition is ${green}${luks_part}${end}\n"
printf "Press ${green}ENTER${end} to continue\n"
read cont

# Encrypt LUKS partition
echo -e "${green}Encrypting ${luks_part}...${end}"
cryptsetup luksFormat ${luks_part}

# Open encrypted partition
luks_name="root"
cryptsetup open ${lukspart} ${luks_name}

# Create filesystems
mkfs.fat -F32 ${efipart}
mkfs.btrfs /dev/mapper/${luks_name}

# Create temp mount directory and mount
mkdir /target
mount /dev/mapper/${luks_name} /target
cd /target

# Create root subvolume
btrfs subvolume create @

# Create swap subvolume
btrfs subvolume create @swap
btrfs filesystem mkswapfile --size 4g --uuid clear @swap/swapfile; # Might switch to zram
cd ${CURRENTDIR}

# Remounting subvolumes
umount /target;
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@ /dev/mapper/${luks_name} /mnt;
mount --mkdir -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@swap /dev/mapper/${luks_name} /mnt/swap;
swapon /mnt/swap/swapfile;

# Mount boot partition
mount --mkdir ${efipart} /mnt/boot
