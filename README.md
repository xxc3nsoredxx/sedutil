![alt tag](https://avatars0.githubusercontent.com/u/13870012?v=3&s=200)

AMD RYZEN: This fork is for AMD Ryzen systems that cannot boot with standard sedutil

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

***** sleep (S3) is not supported.

Orginal source code is available on GitHub at https://github.com/Drive-Trust-Alliance/sedutil 

Linux and Windows executables are available at https://github.com/Drive-Trust-Alliance/sedutil/wiki/Executable-Distributions

# About SEDutil for AMD Ryzen

DTA sedutil: For AMD Ryzen Systems

The sedutil project provides a CLI tool (`sedutil-cli`) capable of setting up and managing self encrypting drives (SEDs) that comply with the TCG OPAL 2.00 standard. This project also provides a pre-boot authentication image (`linuxpba`) which can be loaded onto an encrypted disk's shadow MBR. This pre-boot authentication image allows the user enter their password and unlock SED drives during the boot process. **Using this tool can make data on the drive inaccessible!**


## Setup

To configure a drive, load a compatible [RECOVERY](https://github.com/Drive-Trust-Alliance/sedutil/releases) image onto a USB drive and follow the instructions here:  

https://github.com/Drive-Trust-Alliance/sedutil/wiki/Encrypting-your-drive  


## Origin

This version of sedutil is based off the original [@dta](https://github.com/Drive-Trust-Alliance/sedutil/) implementation as modified by [@dta](https://github.com/lukefor/sedutil). This fork adds support for the PBA bootloader to work on AMD Ryzen and AMD Ryzen mobile systems.


## Notable Differences

Unique to this repo are the following modifications:

* Compatibile with AMD Ryzen and mobile AMD Ryzen systems


## Build Process

Building is supported on Ubuntu 18.04.3 (LTS) x64. Other versions will probably not compile correctly!

To compile your own version of `sedutil` you will need the standard development tools, an internet connection, and ~10 GB of disk space. 

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

I have only tested the boot images/release files on a HP x360 Envy AMD 3700u with a Samsung EVO 970 Plus 2TB NVMe drive. My testing has also focused only on the 64 bit UEFI images. While the other variants might work, you should exercise caution, and if possible, test the release on a computer with data that is expendable.

Follow the instructions here:  
https://github.com/Drive-Trust-Alliance/sedutil/wiki/Encrypting-your-drive  
