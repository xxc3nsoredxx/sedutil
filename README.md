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

Source code is available on GitHub at https://github.com/Drive-Trust-Alliance/sedutil 

Linux and Windows executables are available at https://github.com/Drive-Trust-Alliance/sedutil/wiki/Executable-Distributions

If you are looking for the PSID revert function see linux/PSIDRevert_LINUX.txt or win32/PSIDRevert_WINDOWS.txt

PLEASE SEE CONTRIBUTING if you would like to make a code contribution.

How to build (Ubuntu 16.04):

Install dependencies:  
apt-get update  
apt-get upgrade  
apt-get install \  
      build-essential autoconf pkg-config libc6-dev make \   
	  g++-multilib m4 libtool ncurses-dev unzip zip git python \  
      zlib1g-dev wget bsdmainutils automake curl bc \  
      rsync cpio git nasm   

git clone https://github.com/ChubbyAnt/sedutil.git  
cd images/  
run:  
./getresources  
run:  
./buildpbaroot  
(this takes a long time)  
run:  
./buildUEFI64   
run:  
./buildbios  
run:  
./buildrescue Rescue64  
run:  
./buildrescue Rescue32  

Download the img files created by these operations, then follow the instructions here:  
https://github.com/Drive-Trust-Alliance/sedutil/wiki/Encrypting-your-drive  
