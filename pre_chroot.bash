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

# Create a GPT Partition table
parted -s ${root_drive} mklabel gpt

# Create the boot partition
parted -s ${root_drive} mkpart primary fat32 1MiB 2048MiB

# Create the OS partition
parted -s ${root_drive} mkpart primary 2048MiB 100%

# Set the boot flags for the boot partition
parted -s ${root_drive} set 1 esp on


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
cryptsetup open ${luks_part} ${luks_name}

# Create filesystems
mkfs.fat -F32 ${efi_part}
mkfs.btrfs /dev/mapper/${luks_name}

# Create temp mount directory and mount
mkdir /target
mount /dev/mapper/${luks_name} /target
cd /target

# Create root subvolume
btrfs subvolume create @

# Create home subvolume
#btrfs subvolume create @home # Uncomment for home subvolume

# Create swap subvolume
filesz=$(free -h | grep 'Mem' | awk '{print $2}' | tr -d "A-Za-z")
btrfs subvolume create @swap
btrfs filesystem mkswapfile --size ${filesz}g --uuid clear @swap/swapfile; # Might switch to zram
cd ${CURRENTDIR}

# Remounting subvolumes
umount /target;
mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@ /dev/mapper/${luks_name} /mnt
#mount -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@home /dev/mapper/${luks_name} /mnt # Uncomment for home subvolume
mount --mkdir -o noatime,compress=zstd,discard=async,space_cache=v2,subvol=@swap /dev/mapper/${luks_name} /mnt/swap;
swapon /mnt/swap/swapfile;

# Mount boot partition
mount --mkdir ${efi_part} /mnt/boot

# installing the base system
pacstrap -K /mnt base linux linux-firmware linux-headers networkmanager cryptsetup btrfs-progs grub grub-btrfs efibootmgr vim sudo base-devel;

# generate fstab and write it to rootdrive
genfstab -U /mnt >> /mnt/etc/fstab;

# copy chroot setup to target system
cp ./post_chroot.bash /mnt/

# Store uuid of root part
rootuuid=$(sudo blkid -s UUID -o value ${luks_part})

# chrooting into the new system
arch-chroot /mnt ./post_chroot.bash ${rootuuid} ${luks_name}

# remove chroot script
rm /mnt/post_chroot.bash

# user specific configuration
arch-chroot /mnt;
