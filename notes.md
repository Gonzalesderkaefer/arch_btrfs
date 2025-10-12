

## Partition the drive with parted

Create new partition table
```
parted -s /dev/<device_name> mklabel gpt
```


Create the boot partition
```
parted -s /dev/<device_name> mkpart primary fat32 1MiB 2048MiB
```


Create the luks partition
```
parted -s /dev/<device_name> mkpart primary 2048MiB 100%
```

set flags for boot partition
```
parted -s /dev/<device_name> set 1 esp on
```
