## TODO: clean up the warns from -Wextra
## common_flags = -Wall -Wextra -Os
common_flags = -Wall -Os
AM_CFLAGS = $(common_flags) -std=c11
AM_CPPFLAGS = -ICommon -ICommon/pbkdf2 -Ilinux -ILinuxPBA
AM_CXXFLAGS = $(common_flags) -std=c++11 

sbin_PROGRAMS = sedutil-cli linuxpba
man_MANS = docs/sedutil-cli.8

SEDUTIL_COMMON_CODE = Common/DtaAnnotatedDump.cpp Common/DtaAnnotatedDump.h
SEDUTIL_COMMON_CODE += Common/DtaCommand.cpp Common/DtaCommand.h
SEDUTIL_COMMON_CODE += Common/DtaDev.cpp Common/DtaDev.h
SEDUTIL_COMMON_CODE += Common/DtaDevEnterprise.cpp Common/DtaDevEnterprise.h
SEDUTIL_COMMON_CODE += Common/DtaDevGeneric.cpp Common/DtaDevGeneric.h
SEDUTIL_COMMON_CODE += Common/DtaDevOpal1.cpp Common/DtaDevOpal1.h
SEDUTIL_COMMON_CODE += Common/DtaDevOpal2.cpp Common/DtaDevOpal2.h
SEDUTIL_COMMON_CODE += Common/DtaDevOpal.cpp Common/DtaDevOpal.h
SEDUTIL_COMMON_CODE += Common/DtaDiskType.cpp Common/DtaDiskType.h
SEDUTIL_COMMON_CODE += Common/DtaHashPwd.cpp Common/DtaHashPwd.h
SEDUTIL_COMMON_CODE += Common/DtaHexDump.cpp Common/DtaHexDump.h
SEDUTIL_COMMON_CODE += Common/DtaResponse.cpp Common/DtaResponse.h
SEDUTIL_COMMON_CODE += Common/DtaSession.cpp Common/DtaSession.h
SEDUTIL_COMMON_CODE += Common/DtaStructures.h Common/log.h Common/DtaLexicon.h Common/DtaConstants.h Common/DtaEndianFixup.h
SEDUTIL_COMMON_CODE += Common/pbkdf2/blockwise.c Common/pbkdf2/blockwise.h Common/pbkdf2/chash.c Common/pbkdf2/chash.h Common/pbkdf2/handy.h
SEDUTIL_COMMON_CODE += Common/pbkdf2/hmac.c Common/pbkdf2/hmac.h Common/pbkdf2/pbkdf2.c Common/pbkdf2/pbkdf2.h Common/pbkdf2/sha512.c
SEDUTIL_COMMON_CODE += Common/pbkdf2/sha2.h Common/pbkdf2/tassert.h Common/pbkdf2/bitops.h

sedutil_cli_SOURCES = Common/sedutil.cpp Common/DtaOptions.cpp Common/DtaOptions.h
sedutil_cli_SOURCES += linux/DtaDevLinuxNvme.cpp linux/DtaDevLinuxNvme.h
sedutil_cli_SOURCES += linux/DtaDevLinuxSata.cpp linux/DtaDevLinuxSata.h
sedutil_cli_SOURCES += linux/DtaDevOS.cpp linux/DtaDevOS.h
sedutil_cli_SOURCES += linux/DtaDevLinuxDrive.h linux/os.h
sedutil_cli_SOURCES += $(SEDUTIL_COMMON_CODE)
nodist_sedutil_cli_SOURCES = linux/Version.h

linuxpba_SOURCES = LinuxPBA/LinuxPBA.cpp LinuxPBA/GetPassPhrase.cpp LinuxPBA/UnlockSEDs.cpp
linuxpba_SOURCES += LinuxPBA/GetPassPhrase.h LinuxPBA/UnlockSEDs.h
linuxpba_SOURCES += linux/DtaDevLinuxNvme.cpp linux/DtaDevLinuxNvme.h
linuxpba_SOURCES += linux/DtaDevLinuxSata.cpp linux/DtaDevLinuxSata.h
linuxpba_SOURCES += linux/DtaDevOS.cpp linux/DtaDevOS.h
linuxpba_SOURCES += linux/DtaDevLinuxDrive.h linux/os.h
linuxpba_SOURCES += $(SEDUTIL_COMMON_CODE)

CLEANFILES = linux/Version.h
BUILT_SOURCES = linux/Version.h
EXTRA_DIST = Common/pbkdf2/COPYING docs/sedutil-cli.8 linux/GitVersion.sh FEATURES.md LICENSE README.md

linux/Version.h:
	./linux/GitVersion.sh > linux/Version.h
.PRECIOUS: linux/Version.h
.INTERMEDIATE: linux/Version.h
