# Cut Features
These features were cut to reduce potential attack vectors and to shrink the size of the PBA and rescue images.

**NOTE:**
Some of these (such as POSIX threads, syslog, and SuS legacy functions) are used by build-time dependencies and only therefore included.
Some extraneous will be removed in future builds (if possible).

## Linux kernel
The kernel, as configured by DTA (extracted from their downloads), is nearly 1 MiB larger than the day-to-day kernel I run on my laptop!
These cuts shrunk the kernel image down to under 1/3 the original size:
* Virtualization
  * The PBA and rescue image have no need for running any virtual machines
  * This adds unnecessary bloat to the image
* Kernel modules
  * Everything needed to manage Opal 2 drives is included in the kernel
  * Loading kernel modules at runtime has the potential to introduce vulnerabilities
* Networking
  * The PBA and rescue image have no need for networking
  * Accessing the network has the potential to introduce vulnerabilities
* Filesystems
  * Everything necessary is included in the initramfs and is loaded into RAM
  * proc, devtmpfs, and ramfs are all that is needed
  * Accessing arbitrary filesystems has the potential to introduce vulnerabilities
  * Additionally, accessing arbitrary filesystems has the potential to damage a user's existing files
* Graphics
  * Graphics support is useless in the PBA and rescue image
  * This adds unnecessary bloat to the image
  * The only graphics included is EFI framebuffer
* SMP
  * The PBA and rescue image have no need for running on multiple cores
  * This adds unnecessary bloat to the image
* Multilib
  * x86 is becoming rarer and rarer
  * 32 bit systems are likely running on BIOS, which is unsupported in this version of sedutil
  * This adds unnecessary bloat to the image
* Pseudoterminals
  * Everything runs on the TTY
  * This adds unnecessary bloat to the image
* USB
  * Accessing external storage has the potential to introduce vulnerabilities
* SD/MM/SDIO cards
  * Accessing external storage has the potential to introduce vulnerabilities
* Users
  * The utilites require root permission to function
  * This adds unnecessary bloat to the image

Anything not listed, but cut, was mainly to remove unnecessary bloat from the image.
See [the kernel defconfig](images/sedutil/board/kernel.config) for a detailed list if interested.

## uClibc
The original version linked against glibc.
Switching to a stripped down uClibc shrunk the initramfs to 1/2 the original size.

Listing cut features would make this list unbearably long.
Plus, it's also useful to know what _is_ available:
* MMU
  * Any change is overridden by Buildroot
* Floating point (including FPU)
  * Any change is overridden by Buildroot
* C99 math library
* Dynamic library
* Native POSIX threads
  * Any change is overridden by Buildroot
* syslog
* Dynamic `atexit(3)`
* SuSv3/v4 legacy functions
* Shadow passwords
* Linux specific functions
* BSD `err*` functions
* Realtime-/advanced realtime-related POSIX functions
* libcrypt with SHA512
* Networking (sockets)
* Hexadecimal floats in string functions
* glibc `register_printf_function()`
* Macros for `getc(3)` and `putc(3)`
* Auto-transition between read and write for file descriptors
* `x` flag for `fopen(3)`
* `%m` format specifier
* errno message text
* signum message text
* GNU `getopt(3)`
* POSIX regex
* POSIX `fnmatch(3)`
* `glob(3)`
* `-fstack-protector`
  * build uClibc with stack protection

## BusyBox
BusyBox contains several utilites which are generally considered useful.
Some of them are incompatible with the stripped down versions of the kernel and uClibc.
Most of them are useless for managing Opal 2 drives in the rescue image.
These cuts shrunk the BusyBox binary down to under 1/3 the original size.

Listing cut features would make this list unbearably long.
Plus, it's also useful to know what _is_ available:
* SuSv2 compatibility
* `--long-option`
* `LOG_INFO` for syslog
* PIE binaries
* Applets installed as symlinks
* `RTMIN[+n]` and `RTMAX[-n]` signal names
* Shrink MD5 and SHA3 at the expense of speed
* Commandline editing
  * `vi`-style
* History
* Tab-complete
* Archival utilities
  * `xz -d`
* coreutils
  * `cat`, `cp`, `dd` (used by `/dev/urandom` init script), `echo -ne`, `false`,
    `head`, `id`, `ln`, `ls` (with `-pFL` and sorted/colored output), `sha512sum`,
    `mkdir`, `mknod`, `mv`, `rm`, `seq`, `sleep`, `sort`, `tail`, `tee`, `touch`,
    `true`, `uname`, `wc`, "human" output
* Console utilities
  * `clear`, `reset`
* Debian utilities
  * `start-stop-daemon`
* Editors
  * `awk`, `diff`, `patch`, `sed`
* Finding utilities
  * `find` (with `-type -executable -exec ! -depth parens -quit -empty -path -regex`),
    `grep` (with `-ABC`), `xargs`
* Init utilities
  * `poweroff`, `init` (with inittab)
* Login/password utilities
  * Shadow passwords, `getty`, `login`
* System utilities
  * `dmesg`, `xxd`, `hwclock`, `losetup`, `mdev`, `mount` (with `/etc/fstab` and `-o`),
    `uevent`, `umount` (with `-a`), loopback mounts
* Misc utilities
  * `less`
* Process utilities
  * `kill`, `ps`
* Shells
  * Ash
  * Internal `glob(3)` because uClibc is apparently buggy?
  * Bash-compatible extensions
  * Job control
  * PRNG and `$RANDOM`
  * `echo`, `printf`, `test`, `help`, `getopts`, `command` builtins
  * POSIX math
  * Embedded scripts
* Logging utilities
  * `klogd`
