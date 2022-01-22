MAC80211_NODRV_VERSION = 5.10.68-1
MAC80211_NODRV_RELEASE = 1
MAC80211_NODRV_SITE = \
	https://mirrors.kernel.org/pub/linux/kernel/projects/backports/stable/v5.10.68
MAC80211_NODRV_SOURCE = backports-$(MAC80211_NODRV_VERSION).tar.xz
MAC80211_NODRV_LICENSE = GPL-2.0

MAC80211_NODRV_INSTALL_STAGING = YES

MAKE_OPTS = -C "$(@D)" \
	$(LINUX_MAKE_FLAGS) \
	EXTRA_CFLAGS="-I$(@D)/include" \
	KLIB_BUILD="$(LINUX_DIR)" \
	KLIB=$(TARGET_DIR) \

# NOTE: need enable CONFIG_CRYPTO_HASH2 in kernel config
# TODO, use MAC80211_NODRV_LINUX_CONFIG_FIXUPS to fix

MAC80211_NODRV_m := CFG80211 MAC80211
MAC80211_NODRV_y := MAC80211_MESH WLAN \
	CFG80211_WEXT \
	CFG80211_CERTIFICATION_ONUS \
	MAC80211_RC_MINSTREL \
	MAC80211_RC_MINSTREL_HT \
	MAC80211_RC_MINSTREL_VHT \
	MAC80211_RC_DEFAULT_MINSTREL \
	LIB80211 \
	LIB80211_CRYPT_WEP \
	LIB80211_CRYPT_CCMP \
	LIB80211_CRYPT_TKIP


define MAC80211_NODRV_MODULE_PREPARE
	rm -rf \
		$(@D)/include/linux/ssb \
		$(@D)/include/linux/bcma \
		$(@D)/include/net/bluetooth

	rm -f \
		$(@D)/include/linux/cordic.h \
		$(@D)/include/linux/crc8.h \
		$(@D)/include/linux/eeprom_93cx6.h \
		$(@D)/include/linux/wl12xx.h \
		$(@D)/include/linux/spi/libertas_spi.h \
		$(@D)/include/net/ieee80211.h \
		$(@D)/backport-include/linux/bcm47xx_nvram.h

	rm -f $(@D)/.config

	for i in $(MAC80211_NODRV_m); do \
		echo "CPTCFG_$${i}=m" >> $(@D)/.config; \
	done

	for i in $(MAC80211_NODRV_y); do \
		echo "CPTCFG_$${i}=y" >> $(@D)/.config; \
	done

	$(LINUX_MAKE_ENV) $(MAKE) \
		$(MAKE_OPTS) \
		allnoconfig
endef

MAC80211_NODRV_PRE_BUILD_HOOKS += MAC80211_NODRV_MODULE_PREPARE

# do manual patch
define MAC80211_NODRV_DO_PATCH
	$(APPLY_PATCHES) $(@D) $(MAC80211_NODRV_PKGDIR)/patches/build  '*.patch'
	$(APPLY_PATCHES) $(@D) $(MAC80211_NODRV_PKGDIR)/patches/subsys '*.patch'
endef

MAC80211_NODRV_POST_PATCH_HOOKS += MAC80211_NODRV_DO_PATCH

define MAC80211_NODRV_BUILD_CMDS
	rm -rf $(@D)/modules

	$(LINUX_MAKE_ENV) $(MAKE) \
		$(MAKE_OPTS) modules
endef

define MAC80211_NODRV_INSTALL_TARGET_CMDS
    $(LINUX_MAKE_ENV) $(MAKE) \
		-C $(LINUX_DIR) $(LINUX_MAKE_FLAGS) \
		M=$(@D) PWD=$(@D) \
        modules_install
endef


define MAC80211_NODRV_INSTALL_STAGING_CMDS
	mkdir -p \
		$(STAGING_DIR)/usr/include/mac80211 \
		$(STAGING_DIR)/usr/include/mac80211-backport \
		$(STAGING_DIR)/usr/include/net/mac80211

	cp -a $(@D)/net/mac80211/*.h $(@D)/include/* $(STAGING_DIR)/usr/include/mac80211/
	cp -a $(@D)/backport-include/* $(STAGING_DIR)/usr/include/mac80211-backport/
	cp -a $(@D)/net/mac80211/rate.h $(STAGING_DIR)/usr/include/net/mac80211/

	rm -f $(STAGING_DIR)/usr/include/mac80211-backport/linux/module.h

	mkdir -p \
		$(STAGING_DIR)/usr/share/symvers

	cp -a $(@D)/Module.symvers \
		$(STAGING_DIR)/usr/share/symvers/mac80211_nodrv.symvers
endef


$(eval $(generic-package))
