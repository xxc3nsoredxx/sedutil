# sedutil for AMD Ryzen
The sedutil project provides a commandline tool (`sedutil-cli`) for setting up and managing self encrypting drives (SEDs) that comply with the TCG Opal 2.0 standard.
This project also provides a pre-boot authorization (PBA) image (`linuxpba`) which can be loaded onto an encrypted disk's shadow MBR.
The PBA allows the user to enter their password to unlock the SED during the boot process.

To configure a drive, [build the images from source](#building-from-source) or download a prebuilt image from here ***TODO: INSERT RECOVERY RELEASE HERE*** and follow the instructions [further down the page](#encrypting-your-drive).  

S3 sleep is not supported.

This version is based on the sedutil fork by [@ChubbyAnt](https://github.com/ChubbyAnt/sedutil) which is itself based on the original [@DTA](https://github.com/Drive-Trust-Alliance/sedutil/) implementation and forks by [@ladar](https://github.com/ladar/sedutil), [@ckamm](https://github.com/ckamm/sedutil/) and [@CyrilVanErsche](https://github.com/CyrilVanErsche/sedutil/).

## Notable Differences
**IMPORTANT:**
This version of sedutil is not compatible with SHA-1 versions of sedutil.

This version has the following modifications:
* SHA512 password hashing vs SHA1 in the original sedutil
* Compatibile with AMD Ryzen systems
* Cleaner `linuxpba` runtime
  * New "boot authorization" prompt
  * No excessive debug output
* New build system
  * Uses a proper Buildroot external tree for improved maintainability
* Only NVMe drive support
  * Well, AFAIK. I don't have any other types of drives to test with.
* No BIOS support
* Minimally sized images
  * UEFI image (the PBA itself)
    * Original DTA size: 32 MiB (uncompressed)
    * My size: 3 MiB (uncompressed)
  * RESCUE image
    * Original DTA size: 75 MiB (uncompressed)
    * My size: 5.5 MiB (uncompressed)
* Newer, stripped down kernel for a decreased attack surface
  * Linux 5.4.80
  * Original DTA bzImage size: 6.3 MiB
  * My bzImage size: 1.9 MiB
  * Cut features
    * No virtualization support
    * No kernel module support
    * No networking support
    * No filesystem support
      * Excluding proc, devtmpfs, and ramfs
    * No graphics support
      * Excluding EFI framebuffer
    * No SMP support
    * No multilib support
    * No pseudoterminal support
    * No USB support
    * No SD/MMC/SDIO card support
    * No multi-user support
* Stripped down BusyBox
  * Original BusyBox size: 714 KiB (as measured from `output/target/bin/busybox`)
  * My BusyBox size: 228 KiB
  * Cut features
    * Incompatible features (such as no kernel support)
    * Non-essential features (bells and whistles not needed to manage Opal 2 drives)
    * For the list, see the commits starting here:
[c954e8f7](https://github.com/xxc3nsoredxx/sedutil/commit/c954e8f74a253c60e026d6e70051ebd0446a227d)
* uClibc instead of glibc
  * Cut the size of the initramfs in half
* BusyBox patches
  * loginutils/getty.c
    * Display `/etc/issue` when not prompting for login
    * `-r` flag to automatically log in as `root`
  * libbb/login.c
    * `\C` to clear the screen when parsing `/etc/issue`

## Tested hardware
* Thinkpad T14, Ryzen 7 PRO 4750U, Samsung 970 EVO Plus 1 TB NVMe M.2

If anyone uses this to set up Opal 2 on different hardware, please submit a pull request updating the list with whether it works or not.

# Building from Source
Release builds are made on Gentoo amd64.
Any Linux distribution should work as long as the dependencies are available.

## Dependencies and Requirements
* prepare.sh
  * Source downloads
    * `curl`, `tar`, `gzip`
    * Working Internet connection (uses Buildroot's `make source` to fetch all the necessary tarballs before the build is started)
  * sedutil tarball creation
    * `autoconf`, `sed`, `make`, `tar`, `xz-utils`
* Buildroot
  * `which`, `sed`, `make`, `binutils`, `build-essential` (Debian), `gcc`, `g++`, `bash`,
    `patch`, `gzip`, `bzip2`, `perl`, `tar`, `cpio`, `unzip`, `rsync`, `file`, `bc`, `wget`
* flash_rescue.sh
  * root permissions to be able to write to a block device
* Minimum 7 GiB of free space on disk
  * 12 GiB to safely accommodate the maximum `ccache` size of 5 GiB
* Boot images
  * The `libata.allow_tpm` kernel option set to `1`

Run `images/check_deps.sh` to test for missing dependencies.
Doesn't test for `bash`, `which`, Debian's `build-essential`, Internet connection, or availability of root permissions.
If you're not customizing the images further yourself, the `libata.allow_tpm` requirement is handled by the SYSLINUX config file.

## Build
`$` denotes user commands

`#` denotes root commands
```
$ cd images
$ ./prepare.sh
$ ./build.sh
[Insert the USB where the rescue image will be written to]
# ./flash_rescue.sh
```
If the flash drive does not show up in the list when running `flash_rescue.sh`, cancel by hitting `Ctrl-C` and try again.
It can take a little bit for the device to be recognized by the kernel and be available for use.

## Modifying the Included Configuration
To modify any of the configs, run the following after running the `prepare.sh` script:
```
$ cd scratch/buildroot
$ make [target]
```

The following `make` targets are of interest:
* `menuconfig`
  * Buildroot configurator
* `linux-menuconfig`
  * Linux kernel configurator
* `busybox-menuconfig`
  * BusyBox configurator
* `uclibc-menuconfig`
  * uClibc configurator

To control the level of debug output for `sedutil-cli` and `linuxpba`, change the following `Kconfig` option using the Buildroot configurator:
```
External options  --->
      *** xxc3nsoredxx sedutil fork (in /local/path/to/external/tree) ***
  [*] sedutil (xxc3nsoredxx's fork)
        sedutil debug level (INFO)  --->
```
The default level is `INFO`.

# Encrypting Your Drive
**IMPORTANT:**
This process _should_ leave the data on the drive intact, but ***ABSLUTELY NO GUARANTEES ARE MADE.***
Before continuing, ensure you have a working backup of any data you wish to keep.

This page is based on the information found on the DTA repo's [wiki](https://github.com/Drive-Trust-Alliance/sedutil/wiki/Encrypting-your-drive).
Reading their guides can give a bit more information, but it may or may not be fully compatible with this version of the software:

**NOTE:**
Both the PBA and the rescue system uses the us_english keyboard layout.
This can cause issues when setting the password on your normal operating system if you use another keyboard layout.
To make sure the PBA recognizes your password, and to protect your existing OS, you should set up your drive from the rescue system as described on this page.

## Prepare a Bootable Rescue System
These instructions are for a UEFI system that is running Linux (either installed on the hardware or through a live boot).
Secure boot must also be disabled.
BIOS systems are unsupported.

1. Download the rescue image
2. Insert a USB drive
   * Almost any will do, the image is 5.5 MiB in size
3. Decompress the image
   * `unxz RESCUE-*.img.xz`
4. Flash the image onto the USB (requires root)
   * `dd if=RESCUE-*.img of=/dev/sdX`
   * Replace `sdX` with the correct block device corresponding to the USB drive

**NOTE:**
If building from source, running the `flash_rescue.sh` script during the build process handles the above.

Reboot the machine from the USB drive.
Once it has loaded it will drop directly into a root shell.
Run `sedutil-cli --scan` to check for supported drives.

Example output:
```
#sedutil-cli --scan
Scanning for Opal compliant disks
/dev/nvme0  2  Samsung SSD 970 EVO Plus 1TB             2B2QEXM7
No more disks present ending scan
```

Verify that the second column contains a '2' which indicates that the drive has Opal 2 support.
If it does not, abort now.
The software cannot detect Opal 2 support on the drive, and continuing may erase all the data on your drive.

## Test the PBA
Run `linuxpba` and enter `debug` as the password when prompted.
Using a different password will reboot the system.

Example output:
```
#linuxpba 
Boot Authorization Key: *****
Scanning....
Drive /dev/nvme0 Samsung SSD 970 EVO Plus 1TB             is OPAL NOT LOCKED
```

Verify that your drive is listed and is reported as `is OPAL`.
If it is not, abort now.
The next sections enable Opal locking on the drive, and it is imperative that the drive is detected correctly.
If any problems are encountered, follow the instructions in the [Recovery Information](https://github.com/Drive-Trust-Alliance/sedutil/wiki/Encrypting-your-drive#recovery-information) section (on the DTA wiki) to disable or remove Opal locking.

The next sections assume the target drive is on `/dev/nvme0`.
Replace with the appropriate block device if needed.

## Enable Locking and Install the PBA
Run the following commands:
```
xz -d /usr/sedutil/UEFI-*.img.xz
sedutil-cli --initialsetup debug /dev/nvme0
sedutil-cli --enablelockingrange 0 debug /dev/nvme0
sedutil-cli --setlockingrange 0 lk debug /dev/nvme0
sedutil-cli --setmbrdone off debug /dev/nvme0
sedutil-cli --loadpbaimage debug /usr/sedutil/UEFI-*.img /dev/nvme0
```
Unlike on standard systems, `unxz` will not work in the rescue image &mdash; `xz -d` is required.
The name of the PBA image may (and should) be tab-completed to ensure it is correct.
The initial password of `debug` will be changed in a later step.
The third `sedutil-cli` command's third argument is "ell-kay".

Example output:
```
#xz -d /usr/sedutil/UEFI-*.img.xz
#sedutil-cli --initialsetup debug /dev/nvme0
takeOwnership complete
Locking SP Activate Complete
LockingRange0 disabled
LockingRange0 set to RW
MBRDone set on
MBRDone set on
MBREnable set on
Initial setup of TPer complete on /dev/nvme0
#sedutil-cli --enablelockingrange 0 debug /dev/nvme0
LockingRange0 enabled ReadLocking,WriteLocking
#sedutil-cli --setlockingrange 0 lk debug /dev/nvme0
LockingRange0 set to LK
#sedutil-cli --setmbrdone off debug /dev/nvme0
MBRDone set off
#sedutil-cli --loadpbaimage debug /usr/sedutil/UEFI-*.img /dev/nvme0
Writing PBA to /dev/nvme0
3059712 of 3059712 100% blk=54346
```

## Test the PBA (again)
Run `linuxpba` and enter `debug` as the password when prompted.

Example output:
```
#linuxpba 
Boot Authorization Key: *****
Scanning....
Drive /dev/nvme0 Samsung SSD 970 EVO Plus 1TB             is OPAL Unlocked
```

Verify that your drive is listed and is reported as `Unlocked`.
If it is not, abort now and follow the instructions linked above to disable or remove Opal locking.

## Set the Password
Run the following commands to set the `SID` and `Admin1` passwords.
They don't have to match, but it makes future administartion easier.
```
sedutil-cli --setsidpassword debug <password> /dev/nvme0
sedutil-cli --setadmin1pwd debug <password> /dev/nvme0
```

Example output:
```
#sedutil-cli --setsidpassword debug <password> /dev/nvme0
#sedutil-cli --setadmin1pwd debug <password> /dev/nvme0
Admin1 password changed
```

## Finalize
Run the following commands to finalize setting up the drive.
It also serves as a way to check if your password works.
```
sedutil-cli --setmbrdone on <password> /dev/nvme0
poweroff
```

Example output:
```
#sedutil-cli --setmbrdone on <password> /dev/nvme0
MBRDone set on
#poweroff
[machine powers off]
```

The drive is now set to use Opal 2!
This will _completely power off the system_ so that the drive will lock.
On the next boot, the drive will present the shadow MBR to the system and the PBA will boot.
After entering your password, the machine will reboot.
If the password was entered correctly, the drive will be unlocked, the actual contents of the drive will be visible, and the boot will continue as normal.

# Updating the PBA Image
**IMPORTANT:**
This assumes your disk is already using Opal 2 locking.
If your disk is not using Opal 2, follow the instructions above to enable.
This process _should_ leave the data on the drive intact, but ***ABSLUTELY NO GUARANTEES ARE MADE.***
Before continuing, ensure you have a working backup of any data you wish to keep.

These next sections assume the target drive is on `/dev/nvme0`.
Replace with the appropriate block device if needed.

## Prepare a Bootable Rescue System
Follow the instructions above to create a rescue system on a USB drive.
Once done, power off the machine completely to lock the drive.
Then boot the machine from the USB drive.
Once booted, run `sedutil-cli --scan` as a sanity check.

Example output:
```
#sedutil-cli --scan
Scanning for Opal compliant disks
/dev/nvme0  2  Samsung SSD 970 EVO Plus 1TB             2B2QEXM7
No more disks present ending scan
```

## Unlock the Drive
To unlock the drive, run `linuxpba` and enter your current password when prompted.

Example output:
```
#linuxpba
Boot Authorization Key: *****
Scanning....
- 18:02:25.627 INFO: MBRDone set on
- 18:02:26.267 INFO: LockingRange0 set to RW
Drive /dev/nvme0 Samsung SSD 970 EVO Plus 1TB             is OPAL Unlocked
```

## Flash the New PBA Image
To flash the updated image, run the following commands to decompress the image, switch to the shadow MBR, and flash the image:
```
xz -d /usr/sedutil/UEFI-*.img.xz
sedutil-cli --setmbrdone off <password> /dev/nvme0
sedutil-cli --loadpbaimage <password> /usr/sedutil/UEFI-*.img /dev/nvme0
```
Unlike on standard systems, `unxz` will not work in the rescue image &mdash; `xz -d` is required.
The name of the PBA image may (and should) be tab-completed to ensure it is correct.

Example output:
```
#xz -d /usr/sedutil/UEFI-*.img.xz
#sedutil-cli --setmbrdone off debug /dev/nvme0
MBRDone set off
#sedutil-cli --loadpbaimage debug /usr/sedutil/UEFI-*.img /dev/nvme0
Writing PBA to /dev/nvme0
3059712 of 3059712 100% blk=54346
```

## Finalize
To finalize the drive, switch out of the shadow MBR and power off the machine by running the following commands:
```
sedutil-cli --setmbrdone on <password> /dev/nvme0
poweroff
```

Example output:
```
#sedutil-cli --setmbrdone on <password> /dev/nvme0
MBRDone set on
#poweroff
[machine powers off]
```

This will _completely power off the system_ so that the drive will lock.
On the next boot, the drive will present the shadow MBR to the system and the updated PBA will boot.
After entering your password, the machine will reboot.
If the password was entered correctly, the drive will be unlocked, the actual contents of the drive will be visible, and the boot will continue as normal.

# Copyright
This software is Copyright 2014-2017 Bright Plaza Inc. <drivetrust@drivetrust.com>

Copyright 2020-2021 xxc3nsoredxx

This file is part of sedutil.

sedutil is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

sedutil is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with sedutil.  If not, see <http://www.gnu.org/licenses/>.
