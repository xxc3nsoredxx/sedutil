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
SEDUTIL_XXC_DEPENDENCIES += host-gawk

# Set the debug level
ifeq ($(BR2_PACKAGE_SEDUTIL_XXC_DEBUG_ERROR),y)
SEDUTIL_XXC_CONF_OPTS += --enable-debug=ERROR
else ifeq ($(BR2_PACKAGE_SEDUTIL_XXC_DEBUG_WARN),y)
SEDUTIL_XXC_CONF_OPTS += --enable-debug=WARN
else ifeq ($(BR2_PACKAGE_SEDUTIL_XXC_DEBUG_INFO),y)
SEDUTIL_XXC_CONF_OPTS += --enable-debug=INFO
else ifeq ($(BR2_PACKAGE_SEDUTIL_XXC_DEBUG_DEBUG),y)
SEDUTIL_XXC_CONF_OPTS += --enable-debug=DEBUG
else ifeq ($(BR2_PACKAGE_SEDUTIL_XXC_DEBUG_DEBUG1),y)
SEDUTIL_XXC_CONF_OPTS += --enable-debug=DEBUG1
else ifeq ($(BR2_PACKAGE_SEDUTIL_XXC_DEBUG_DEBUG2),y)
SEDUTIL_XXC_CONF_OPTS += --enable-debug=DEBUG2
else ifeq ($(BR2_PACKAGE_SEDUTIL_XXC_DEBUG_DEBUG3),y)
SEDUTIL_XXC_CONF_OPTS += --enable-debug=DEBUG3
else ifeq ($(BR2_PACKAGE_SEDUTIL_XXC_DEBUG_DEBUG4),y)
SEDUTIL_XXC_CONF_OPTS += --enable-debug=DEBUG4
else
SEDUTIL_XXC_CONF_OPTS += --enable-debug=INFO
endif

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
