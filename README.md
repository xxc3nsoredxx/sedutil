![alt tag](https://avatars0.githubusercontent.com/u/13870012?v=3&s=200)

AMD Ryzen: This SEDutil fork includes support for AMD Ryzen systems with SHA-512 password authentication.

Note: This version of SEDutil is not compatible with SHA-1 versions of SEDutil.

This software is Copyright 2014-2017 Bright Plaza Inc. <drivetrust@drivetrust.com>

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

sedutil - The Drive Trust Alliance Self Encrypting Drive Utility

This program and it's accompanying Pre-Boot Authorization image allow
you to enable the locking in SED's that comply with the TCG OPAL 2.00
standard on bios machines.   

You must be administrator/root to run the host managment program

In Linux libata.allow_tpm must be set to 1. Either via adding libata.allow_tpm=1 to the kernel flags at boot time 
or changing the contents of /sys/module/libata/parameters/allow_tpm from a "0" to a "1" on a running system.

***sleep (S3) is not supported.***

Orginal source code is available on GitHub at https://github.com/Drive-Trust-Alliance/sedutil 

Linux and Windows executables and Linux PBA bootloader images for this version of SEDutil are available at ***TODO: INSERT RELEASE BUILDS HERE***

# About SEDutil for AMD Ryzen
DTA sedutil: For AMD Ryzen Systems

The sedutil project provides a CLI tool (`sedutil-cli`) capable of setting up and managing self encrypting drives (SEDs) that comply with the TCG OPAL 2.00 standard.
This project also provides a pre-boot authentication image (`linuxpba`) which can be loaded onto an encrypted disk's shadow MBR.
This pre-boot authorization image allows the user enter their password and unlock SED drives during the boot process.
**Using this tool can make data on the drive inaccessible!**

## Setup
To configure a drive, load a compatible ***TODO: INSERT RECOVERY RELEASE HERE*** image onto a USB drive and follow the instructions here:  

https://github.com/Drive-Trust-Alliance/sedutil/wiki/Encrypting-your-drive

This has so far only been tested and confirmed to work on my ThinkPad T14 with Ryzen 7 PRO 4750U, 32 GiB of RAM, and a Samsung 970 EVO Plus 1 TiB NVMe M.2.
If anyone uses this to set up OPAL 2 on different hardware, please submit a pull request updating the list with whether it works or not.

## Origin
This version is based on the sedutil fork by [@ChubbyAnt](https://github.com/ChubbyAnt/sedutil) which is itself based on the original [@dta](https://github.com/Drive-Trust-Alliance/sedutil/) implementation and incorporates changes by [@ladar](https://github.com/ladar/sedutil), [@ckamm](https://github.com/ckamm/sedutil/) and [@CyrilVanErsche](https://github.com/CyrilVanErsche/sedutil/).
In addition to adding support for the PBA bootloader on AMD Ryzen and AMD Ryzen mobile systems, this fork uses a revamped build system.

## Notable Differences
Unique to this repo are the following modifications:

* SHA512 password hashing vs SHA1 on original SEDutil
* Compatibile with AMD Ryzen and AMD Ryzen mobile systems
* Cleaner `linuxpba` runtime
  * New "boot authorization" prompt
  * No excessive debug output
* New build system
  * Uses a proper Buildroot external tree for improved maintainability
* Only NVMe drive support
  * Well, AFAIK. I don't have any other types of drives to test with.
* No BIOS support
* Minimally sized images
  * UEFI image
    * Original DTA size: 32 MiB (uncompressed)
    * My size: 3 MiB (uncompressed)
  * RESCUE image
    * Original DTA size: 75 MiB (uncompressed)
    * My size: 5.5 MiB (uncompressed)
* Newer, stripped down kernel
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
  * Original BusyBox size: 714 KiB (as measured from output/target/bin/busybox)
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

## Build Process

**NOTE:**
Doxygen formatting has been ignored.
Assume it's broken and doesn't work to generate docs.

Building is supported on Gentoo amd64.
Any distro should work as long as the necessary tooling is available.

To compile your own version of `sedutil` you will need the standard development tools, an internet connection, and at least 7 GiB of disk space. 
Although not mandatory, at least 12 GiB of space is recommended to safely accommodate the maximum `ccache` size of 5 GiB.
`du -d 1 -a -c -h` in the root of the repo says 6.7 GiB for me.

### Dependencies
* prepare.sh
  * Source downloads
    * `curl`, `tar`, `gzip`
  * sedutil tarball creation
    * `autoconf`, `sed`, `make`, `tar`, `xz-utils`
* Buildroot
  * `which`, `sed`, `make`, `binutils`, `build-essential` (Debian), `gcc`, `g++`, `bash`,
    `patch`, `gzip`, `bzip2`, `perl`, `tar`, `cpio`, `unzip`, `rsync`, `file`, `bc`, `wget`

Run `images/check_deps.sh` to test for missing dependencies.
Doesn't test for `bash`, `which`, or Debian's `build-essential`.

### Build

`$` denotes user commands

`#` denotes root commands
```
$ cd images
$ ./prepare.sh
$ ./build.sh
[Insert the USB where the rescue image will be written to]
# ./flash_rescue.sh     (writing to a block device requires root)
```
If the flash drive does not show up in the list when running `flash_rescue.sh`, cancel by hitting `Ctrl-C` and try again.
It can take a little bit for the device to be recognized by the kernel and be available for use.

To control the level of debug output, run the following commands after running `./prepare.sh` but before `./build.sh`:
```
$ cd scratch/buildroot
$ make menuconfig
```
Change the value using the following `Kconfig` option.
The default is `INFO`.
```
External options  --->
      *** xxc3nsoredxx sedutil fork (in /local/path/to/external/tree) ***
  [*] sedutil (xxc3nsoredxx's fork)
        sedutil debug level (INFO)  --->
```
Save the config.
Run `cd ../..` and continue the build as normal.

# Encrypting Your Drive
**IMPORTANT:**
This process _should_ leave the data on the drive intact, but ***ABSLUTELY NO GUARANTEES ARE MADE.***
Before continuing, ensure you have a working backup of any data you wish to keep.

This page is based on the information found on the DTA repo's wiki.
Reading their guides can give a bit more information, but it may or may not be fully compatible with this version of the software:
https://github.com/Drive-Trust-Alliance/sedutil/wiki/Encrypting-your-drive  

**NOTE:**
Both the PBA and the rescue system uses the us_english keyboard layout.
This can cause issues when setting the password on your normal operating system if you use another keyboard layout.
To make sure the PBA recognizes your password, and to protect your existing OS, you should set up you drive from the rescue system as described on this page.

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
If building from source, running the `flash_rescue.sh` script during the build process handles the above for you.

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

Verify that the second column contains a 2 which indicates that the drive has OPAL 2 support.
If it does not, abort now.
The software cannot detect OPAL 2 support on the drive, and continuing may erase all the data on your drive.

## Test the PBA
Run `linuxpba` and enter `debug` as the password when prompted.
Using a different password will reboot the system.

Example output:
```
#linuxpba 
... SNIP DEBUG OUTPUT ...
Drive /dev/nvme0 Samsung SSD 970 EVO Plus 1TB             is OPAL NOT LOCKED
... SNIP DEBUG OUTPUT ...
```

Verify that your drive is listed and is reported as `is OPAL`.
If it is not, abort now.
The next sections enable OPAL locking on the drive, and it is imperative that the drive is detected correctly.
If any problems are encountered, follow the instructions in the [Recovery Information](https://github.com/Drive-Trust-Alliance/sedutil/wiki/Encrypting-your-drive#recovery-information) section to disable or remove OPAL locking.

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
... SNIP DEBUG OUTPUT ...
Drive /dev/nvme0 Samsung SSD 970 EVO Plus 1TB             is OPAL Unlocked
... SNIP DEBUG OUTPUT ...
```

Verify that your drive is listed and is reported as `Unlocked`.
If it is not, abort now and follow the instructions to disable or remove OPAL locking.

## Set the Password
Run the following commands to set the SID and Admin1 passwords.
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

The drive is now set to use OPAL 2!
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
xd -d /usr/sedutil/UEFI-*.img.xz
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
To finalize the drive, switch out of the shadow MBR and power off by running the following commands:
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

# IGNORE ANYTHING BELOW THIS LINE

Prerequisites:  

```
sudo apt-get update && sudo apt-get upgrade -y  
  
sudo apt-get install build-essential autoconf pkg-config libc6-dev make g++-multilib m4 libtool ncurses-dev unzip zip git python zlib1g-dev wget bsdmainutils automake curl bc rsync cpio git nasm -y

```

Automatically Build Everything:  

```
git clone https://github.com/ChubbyAnt/sedutil && cd sedutil && autoreconf --install && ./configure && make all && cd images && ./getresources && ./buildpbaroot && ./buildbios && ./buildUEFI64 && ./buildrescue Rescue32 && ./buildrescue Rescue64 && cd ..
```

Build Everything Manually Step by Step:  

```
git clone https://github.com/ChubbyAnt/sedutil
cd sedutil
autoreconf --install
./configure
make all
cd images
./getresources
./buildpbaroot
./buildbios
./buildUEFI64
./buildrescue Rescue32
./buildrescue Rescue64
cd ..
```

The various recovery and boot images will be located in the `images` directory.


## Testing

This version has only been verified to boot on a HP x360 Envy AMD 3700u with a Samsung EVO 970 Plus 2TB NVMe drive. Testing has also focused only on the 64 bit UEFI images. While the other variants might work, you should exercise caution, and if possible, test the release on a computer with data that is expendable.

# Recovery information:  

If there is an issue after enabling locking you can either disable locking or remove OPAL to continue using your drive without locking.  

If you want to disable Locking and the PBA:  

```
sedutil-cli -–disableLockingRange 0 <password> <drive>  
sedutil-cli –-setMBREnable off <password> <drive>
```

Expected Output:  
```
#sedutil-cli --disablelockingrange 0 debug /dev/nvme0
- 14:07:24.914 INFO: LockingRange0 disabled 
#sedutil-cli --setmbrenable off debug /dev/nvme0
- 14:08:21.999 INFO: MBREnable set off 
```

You can re-enable locking and the PBA using this command sequence:  

```
sedutil-cli -–enableLockingRange 0 <password> <drive>      
sedutil-cli –-setMBREnable on <password> <drive>  
```

Expected Output:  

```
#sedutil-cli --enablelockingrange 0 debug /dev/nvme0
- 14:07:24.914 INFO: LockingRange0 enabled ReadLocking,WriteLocking
#sedutil-cli --setmbrenable on debug /dev/nvme0
- 14:08:21.999 INFO: MBREnable set on 
```

Some OPAL drives have a firmware bug that will erase all of your data if you issue the commands below. See [Remove OPAL](https://github.com/Drive-Trust-Alliance/sedutil/wiki/Remove-OPAL) for a list of drive/firmware pairs that is know to have been tested.  

#To remove OPAL issue these commands:  

```
sedutil-cli --revertnoerase <password> <drive>
```

Expected Output:  

```
#sedutil-cli --revertnoerase debug /dev/nvme0
- 14:22:47.060 INFO: Revert LockingSP complete
```

Verify that the locking SP has been deactivated:  
```
sedutil-cli --query {drive}
```  

Look at the query output and make certain that the Locking section shows ```lockingEnabled=N```

```  
-----
Locking function (0x0002)
Locked = N, LockingEnabled = N, LockingSupported = Y,
---------
```  

If the query does not show lockingEnabled=N DO NOT CONTINUE with the next step, if you do all your data will be erased.  

Remove OPAL:  
```
sedutil-cli --reverttper {SIDpassword} {drive}
```

Expected output:  

```
#sedutil-cli --reverttper debug /dev/nvme0
- 14:23:13.968 INFO: revertTper completed successfully
#
```

When this is finished the drive will be in a non-opal managed state. This would allow you to do anything that you could have done before starting OPAL management under OPAL. You can also reinitiate OPAL management if you wish.
  
  
  
