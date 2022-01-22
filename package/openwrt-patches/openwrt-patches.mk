OPENWRT_PATCHES_VERSION = 21.02.1
OPENWRT_PATCHES_SITE = $(call github,openwrt,openwrt,v$(OPENWRT_PATCHES_VERSION))
OPENWRT_PATCHES_LICENSE = GPL-2.0

define OPENWRT_PATCHES_BUILD_CMDS
    echo "skip build"
endef

define OPENWRT_PATCHES_INSTALL_TARGET_CMDS
	echo "skip install"
endef

$(eval $(generic-package))
