################################################################################
#
# sedutil
#
################################################################################
SEDUTIL_XXC_VERSION = 1.15.1
SEDUTIL_XXC_SOURCE = sedutil-xxc-$(SEDUTIL_XXC_VERSION).tar.xz
SEDUTIL_XXC_SITE = $(SEDUTIL_XXC_PKGDIR)/src
SEDUTIL_XXC_SITE_METHOD = file
SEDUTIL_XXC_LICENSE = GPL-3.0-or-later
SEDUTIL_XXC_INSTALL_STAGING = NO
SEDUTIL_XXC_LIBTOOL_PATCH = NO
SEDUTIL_XXC_INSTALL_TARGET = YES
SEDUTIL_XXC_CONF_OPTS = --sbindir=/sbin
# SEDUTIL_XXC_MAKE=$(MAKE1)
# SEDUTIL_XXC_DEPENDENCIES = libstdc++
# Dont regen version header use the tarball version
define SEDUTIL_XXC_POST_EXTRACT_ACTIONS
	sed -i '/^CLEANFILES/d' $(BUILD_DIR)/sedutil-xxc-$(SEDUTIL_XXC_VERSION)/Makefile.am
	sed -i '/^BUILT_SOURCES/d' $(BUILD_DIR)/sedutil-xxc-$(SEDUTIL_XXC_VERSION)/Makefile.am
	sed -i '/^linux\/Version/,3 d' $(BUILD_DIR)/sedutil-xxc-$(SEDUTIL_XXC_VERSION)/Makefile.am
	sed -i '/^BUILT_SOURCES/d' $(BUILD_DIR)/sedutil-xxc-$(SEDUTIL_XXC_VERSION)/Makefile.in
	sed -i '/^CLEANFILES/d' $(BUILD_DIR)/sedutil-xxc-$(SEDUTIL_XXC_VERSION)/Makefile.in
	sed -i '/^linux\/Version/,3 d' $(BUILD_DIR)/sedutil-xxc-$(SEDUTIL_XXC_VERSION)/Makefile.in
endef
SEDUTIL_XXC_POST_EXTRACT_HOOKS += SEDUTIL_XXC_POST_EXTRACT_ACTIONS
$(eval $(autotools-package))
