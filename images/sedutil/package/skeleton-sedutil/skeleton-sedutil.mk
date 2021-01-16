################################################################################
#
# skeleton-sedutil
#
################################################################################

SKELETON_SEDUTIL_ADD_TOOLCHAIN_DEPENDENCY = NO
SKELETON_SEDUTIL_ADD_SKELETON_DEPENDENCY = NO
SKELETON_SEDUTIL_PROVIDES = skeleton
SKELETON_SEDUTIL_INSTALL_STAGING = YES
SKELETON_SEDUTIL_PATH = $(BR2_EXTERNAL_SEDUTIL_PATH)/board/skeleton

define SKELETON_SEDUTIL_INSTALL_TARGET_CMDS
	$(call SYSTEM_RSYNC,$(SKELETON_SEDUTIL_PATH),$(TARGET_DIR))
	$(call SYSTEM_USR_SYMLINKS_OR_DIRS,$(TARGET_DIR))
	$(call SYSTEM_LIB_SYMLINK,$(TARGET_DIR))
	$(SED) 's,@PATH@,$(BR2_SYSTEM_DEFAULT_PATH),' $(TARGET_DIR)/etc/profile
	$(INSTALL) -m 0644 support/misc/target-dir-warning.txt \
		$(TARGET_DIR_WARNING_FILE)
endef

define SKELETON_INIT_COMMON_INSTALL_STAGING_CMDS
	$(call SYSTEM_RSYNC,$(SKELETON_SEDUTIL_PATH),$(STAGING_DIR))
	$(call SYSTEM_USR_SYMLINKS_OR_DIRS,$(STAGING_DIR))
	$(call SYSTEM_LIB_SYMLINK,$(STAGING_DIR))
	$(INSTALL) -d -m 0755 $(STAGING_DIR)/usr/include
endef

$(eval $(generic-package))
