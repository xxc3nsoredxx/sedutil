################################################################################
#
# syslinux-sedutil
#
################################################################################

SYSLINUX_SEDUTIL_VERSION = 6.03
SYSLINUX_SEDUTIL_SOURCE = syslinux-$(SYSLINUX_SEDUTIL_VERSION).tar.xz
SYSLINUX_SEDUTIL_SITE = $(BR2_KERNEL_MIRROR)/linux/utils/boot/syslinux
SYSLINUX_SEDUTIL_LICENSE = GPL-2.0+
SYSLINUX_SEDUTIL_LICENSE_FILES = COPYING
SYSLINUX_SEDUTIL_INSTALL_TARGET = NO
SYSLINUX_SEDUTIL_INSTALL_IMAGES = YES

# Copy the included syslinux.efi and ldlinux.e64
# The version of SYSLINUX built by Builroot didn't want to work no matter what
# I tried, so this is the workaround
define SYSLINUX_SEDUTIL_INSTALL_IMAGES_CMDS
	$(INSTALL) -D -m 0755 $(@D)/efi64/efi/syslinux.efi \
		$(BINARIES_DIR)/syslinux/bootx64.efi
	$(INSTALL) -D -m 0755 $(@D)/efi64/com32/elflink/ldlinux/ldlinux.e64 \
		$(BINARIES_DIR)/syslinux
	$(INSTALL) -D -m 0755 $(BR2_PACKAGE_SYSLINUX_SEDUTIL_CONFIG) \
		$(BINARIES_DIR)/syslinux
endef

$(eval $(generic-package))
