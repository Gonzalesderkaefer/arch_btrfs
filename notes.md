

## Partition the drive with parted
```
parted -s /dev/<device_name> mklabel gpt
```

```
parted -s /dev/<device_name> mkpart primary fat32 1MiB 2048MiB
```

```
parted -s /dev/<device_name> mkpart primary 2048MiB 100%
```



```
parted -s /dev/<device_name> set 1 esp on
```
