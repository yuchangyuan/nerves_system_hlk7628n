MT76_MT76X8_VERSION = 22b690334c0f49b11534cc2e331c9d5e17c4a0bc
MT76_MT76X8_SITE = $(call github,openwrt,mt76,$(MT76_MT76X8_VERSION))
MT76_MT76X8_LICENSE = GPL-2.0

incflags = -I$(@D) \
	-I$(STAGING_DIR)/usr/include/mac80211-backport/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211-backport \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-include backport/autoconf.h \
	-include backport/backport.h

# enable 802.11 mesh
kcflags = \
	-DCONFIG_MAC80211_MESH

config = \
	CONFIG_MT7603E=m

symvers = $(STAGING_DIR)/usr/share/symvers/mac80211_nodrv.symvers

MT76_MT76X8_MODULE_MAKE_OPTS = \
	$(config) \
	NOSTDINC_FLAGS="$(incflags)" \
	KCFLAGS="$(kcflags)" \
	KBUILD_EXTRA_SYMBOLS="$(symvers)"

# install firmware
define MT76_MT76X8_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware
	cp \
		$(@D)/firmware/mt7628_e1.bin \
		$(@D)/firmware/mt7628_e2.bin \
		$(TARGET_DIR)/lib/firmware

endef

$(eval $(kernel-module))
$(eval $(generic-package))
