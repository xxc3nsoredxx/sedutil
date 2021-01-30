## TODO: clean up the warns from -Wextra
## common_flags = -Wall -Wextra -Os
common_flags = -Wall -Os
AM_CFLAGS = $(common_flags) -std=c11
AM_CPPFLAGS = -Iinclude
AM_CXXFLAGS = $(common_flags) -std=c++11 

sbin_PROGRAMS = sedutil-cli linuxpba
man_MANS = docs/sedutil-cli.8

SEDUTIL_COMMON_INCLUDE  = include/Common/DtaAnnotatedDump.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaCommand.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaConstants.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaDev.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaDevEnterprise.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaDevGeneric.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaDevOpal1.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaDevOpal2.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaDevOpal.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaDiskType.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaEndianFixup.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaHashPwd.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaHexDump.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaLexicon.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaOptions.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaResponse.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaSession.h
SEDUTIL_COMMON_INCLUDE += include/Common/DtaStructures.h
SEDUTIL_COMMON_INCLUDE += include/Common/log.h

SEDUTIL_COMMON_INCLUDE += include/Common/pbkdf2/bitops.h
SEDUTIL_COMMON_INCLUDE += include/Common/pbkdf2/blockwise.h
SEDUTIL_COMMON_INCLUDE += include/Common/pbkdf2/chash.h
SEDUTIL_COMMON_INCLUDE += include/Common/pbkdf2/handy.h
SEDUTIL_COMMON_INCLUDE += include/Common/pbkdf2/hmac.h
SEDUTIL_COMMON_INCLUDE += include/Common/pbkdf2/pbkdf2.h
SEDUTIL_COMMON_INCLUDE += include/Common/pbkdf2/sha2.h
SEDUTIL_COMMON_INCLUDE += include/Common/pbkdf2/tassert.h

SEDUTIL_COMMON_CODE  = Common/DtaAnnotatedDump.cpp
SEDUTIL_COMMON_CODE += Common/DtaCommand.cpp
SEDUTIL_COMMON_CODE += Common/DtaDev.cpp
SEDUTIL_COMMON_CODE += Common/DtaDevEnterprise.cpp
SEDUTIL_COMMON_CODE += Common/DtaDevGeneric.cpp
SEDUTIL_COMMON_CODE += Common/DtaDevOpal1.cpp
SEDUTIL_COMMON_CODE += Common/DtaDevOpal2.cpp
SEDUTIL_COMMON_CODE += Common/DtaDevOpal.cpp
SEDUTIL_COMMON_CODE += Common/DtaDiskType.cpp
SEDUTIL_COMMON_CODE += Common/DtaHashPwd.cpp
SEDUTIL_COMMON_CODE += Common/DtaHexDump.cpp
SEDUTIL_COMMON_CODE += Common/DtaOptions.cpp
SEDUTIL_COMMON_CODE += Common/DtaResponse.cpp
SEDUTIL_COMMON_CODE += Common/DtaSession.cpp

SEDUTIL_COMMON_CODE += Common/pbkdf2/blockwise.c
SEDUTIL_COMMON_CODE += Common/pbkdf2/chash.c
SEDUTIL_COMMON_CODE += Common/pbkdf2/hmac.c
SEDUTIL_COMMON_CODE += Common/pbkdf2/pbkdf2.c
SEDUTIL_COMMON_CODE += Common/pbkdf2/sha512.c

LINUX_INCLUDE  = include/linux/DtaDevLinuxDrive.h
LINUX_INCLUDE += include/linux/DtaDevLinuxNvme.h
LINUX_INCLUDE += include/linux/DtaDevLinuxSata.h
LINUX_INCLUDE += include/linux/DtaDevOS.h
LINUX_INCLUDE += include/linux/os.h

LINUX_CODE  = linux/DtaDevLinuxNvme.cpp
LINUX_CODE += linux/DtaDevLinuxSata.cpp
LINUX_CODE += linux/DtaDevOS.cpp

sedutil_cli_SOURCES  = Common/sedutil.cpp
sedutil_cli_SOURCES += $(LINUX_INCLUDE)
sedutil_cli_SOURCES += $(LINUX_CODE)
sedutil_cli_SOURCES += $(SEDUTIL_COMMON_INCLUDE)
sedutil_cli_SOURCES += $(SEDUTIL_COMMON_CODE)
## nodist_sedutil_cli_SOURCES = include/Version.h

PBA_INCLUDE  = include/LinuxPBA/GetPassPhrase.h
PBA_INCLUDE += include/LinuxPBA/UnlockSEDs.h

linuxpba_SOURCES  = LinuxPBA/LinuxPBA.cpp
linuxpba_SOURCES += LinuxPBA/GetPassPhrase.cpp
linuxpba_SOURCES += LinuxPBA/UnlockSEDs.cpp
linuxpba_SOURCES += $(PBA_INCLUDE)
linuxpba_SOURCES += $(LINUX_INCLUDE)
linuxpba_SOURCES += $(LINUX_CODE)
linuxpba_SOURCES += $(SEDUTIL_COMMON_INCLUDE)
linuxpba_SOURCES += $(SEDUTIL_COMMON_CODE)

CLEANFILES = Version.h
BUILT_SOURCES = Version.h
EXTRA_DIST = Common/pbkdf2/COPYING docs/sedutil-cli.8 utils/GitVersion.sh FEATURES.md LICENSE README.md

Version.h:
	./utils/GitVersion.sh > Version.h
.PRECIOUS: Version.h
.INTERMEDIATE: Version.h
