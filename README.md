# Low_Disk

This disk usage script is designed to gather information on a Linux devices filesystem usage and report on:
- Filesystem Information (Space and Inode usage)
- Largest Directories
- Largest Files
- Large Open Files
- /home/rack usage

## Usage ##

```
Usage : disk_usage_check.sh
Usage : disk_usage_check.sh -f filesystem
```


## Example Output ##


```
============================================================ 
 	 == Filesystem Information == 
============================================================ 

Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/xvda1     ext4   40G  2.8G   35G   8% /

Filesystem     Type  Inodes IUsed   IFree IUse% Mounted on
/dev/xvda1     ext4 2621440 71199 2550241    3% /

============================================================ 
 	 == Largest Directories == 
============================================================ 

2.7G  /
1.6G  /usr

============================================================ 
 	 == Largest Files == 
============================================================ 

106.38M  /var/lib/rpm/Packages
101.13M  /usr/lib/locale/locale-archive
61.08M   /var/cache/yum/x86_64/7/epel/gen/filelists_db.sqlite
51.57M   /boot/initramfs-0-rescue-e270b76eeb584e01b9e5a32b56d37680.img
51.25M   /boot/initramfs-0-rescue-32cb5dd148cd4a9c8f597bdfd32bf7d4.img
43.03M   /var/cache/yum/x86_64/7/base/gen/filelists_db.sqlite
38.89M   /var/cache/driveclient/MossoCloudFS_10041493/z_DO_NOT_DELETE_CloudBackup_v2_0_b6812dbd-956f-40f7-b733-65d11b82725e/backup/b6812dbd-956f-40f7-b733-65d11b82725e-backup.db
36.96M   /var/cache/yum/x86_64/7/updates/gen/filelists_db.sqlite
29.94M   /var/cache/yum/x86_64/7/epel/gen/primary.xml.sqlite
29.20M   /var/cache/yum/x86_64/7/base/gen/primary_db.sqlite
28.54M   /usr/local/bin/driveclient
27.32M   /var/cache/yum/x86_64/7/epel/gen/primary_db.sqlite
27.11M   /var/cache/yum/x86_64/7/epel/gen/primary.xml
19.83M   /usr/lib64/libicudata.so.50.1.2
19M      /usr/lib/firmware/liquidio/lio_23xx_vsw.bin
18M      /var/lib/mysql/ibdata1
17.54M   /var/cache/yum/x86_64/7/epel/gen/updateinfo.xml
17.50M   /boot/initramfs-3.10.0-862.3.3.el7.x86_64.img
17.50M   /boot/initramfs-3.10.0-862.3.2.el7.x86_64.img
17.50M   /boot/initramfs-3.10.0-862.el7.x86_64.img
============================================================

[OK]      No Volume groups (vgs) found

[OK]      No deleted files over 1GB

[WARNING] /home/rack does not appear to exist


============================================================
```
