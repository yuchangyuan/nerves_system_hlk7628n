WPAD_OPENSSL_VERSION = b102f19bcc53c7f7db3951424d4d46709b4f1986
WPAD_OPENSSL_SITE = http://w1.fi/hostap.git
WPAD_OPENSSL_LICENSE = BSD-3-Clause

WPAD_OPENSSL_SITE_METHOD = git

WPAD_OPENSSL_DRIVER_MAKEOPTS := \
	CONFIG_ACS=y \
	CONFIG_DRIVER_NL80211=y \
	CONFIG_IEEE80211N=y
	CONFIG_IEEE80211AC= \
	CONFIG_IEEE80211AX= \
	CONFIG_DRIVER_WEXT=

# enable openssl
WPAD_OPENSSL_DRIVER_MAKEOPTS += \
	CONFIG_TLS=openssl GONFIG_SAE=y

WPAD_OPENSSL_TARGET_LDFLAGS = $(TARGET_LDFLAGS) -lcrypto -lssl

# full
WPAD_OPENSSL_DRIVER_MAKEOPTS += \
	CONFIG_OWE=y CONFIG_SUITEB192=y CONFIG_AP=y CONFIG_MESH=y


# we need rfkill support
WPAD_OPENSSL_DRIVER_MAKEOPTS += \
	NEED_RFKILL=y

# fix ubus
define WPAD_OPENSSL_FIX_UBUS
	sed -i -e 's/struct ubus_object .*;//g' $(1)
endef

define WPAD_OPENSSL_FIX_UBUS_ALL
	$(call WPAD_OPENSSL_FIX_UBUS,$(@D)/src/ap/hostapd.h)
	$(call WPAD_OPENSSL_FIX_UBUS,$(@D)/wpa_supplicant/wpa_supplicant_i.h)
endef

WPAD_OPENSSL_POST_PATCH_HOOKS += WPAD_OPENSSL_FIX_UBUS_ALL

# build process
define Build/Configure/rebuild
	find $(@D) -name \*.o -or -name \*.a | xargs rm -f
	rm -f $(@D)/hostapd/hostapd
	rm -f $(@D)/wpa_supplicant/wpa_supplicant
	rm -f $(@D)/.config_*
endef

define Build/Configure
	$(Build/Configure/rebuild)
	$(if $(wildcard $(WPAD_OPENSSL_PKGDIR)/files/hostapd-full.config), \
		cp $(WPAD_OPENSSL_PKGDIR)/files/hostapd-full.config $(@D)/hostapd/.config \
	)
	$(if $(wildcard $(WPAD_OPENSSL_PKGDIR)/files/wpa_supplicant-full.config), \
		cp $(WPAD_OPENSSL_PKGDIR)/files/wpa_supplicant-full.config $(@D)/wpa_supplicant/.config
	)
	sed -i -e 's/CONFIG_UBUS=y//' $(@D)/hostapd/.config
	sed -i -e 's/CONFIG_UBUS=y//' $(@D)/wpa_supplicant/.config
	rsync -av $(WPAD_OPENSSL_PKGDIR)/src/ $(@D)/
endef


define WPAD_OPENSSL_CONFIGURE_CMDS
	$(Build/Configure)
endef

WPAD_OPENSSL_TARGET_CPPFLAGS = \
	-I$(@D)/src/crypto \
	$(TARGET_CPPFLAGS) \
	-D_GNU_SOURCE

#	-DCONFIG_LIBNL20 \


WPAD_OPENSSL_TARGET_CFLAGS = $(TARGET_CFLAGS) -ffunction-sections -fdata-sections
WPAD_OPENSSL_TARGET_LDFLAGS += -Wl,--gc-sections -lubox

# cfg80211
WPAD_OPENSSL_TARGET_LDFLAGS += -lm -lnl-3 -lnl-genl-3

# dependency
WPAD_OPENSSL_DEPENDENCIES += libnl libubox openssl 

define Build/RunMake
	CFLAGS="$(WPAD_OPENSSL_TARGET_CPPFLAGS) $(WPAD_OPENSSL_TARGET_CFLAGS)" \
	$(TARGET_MAKE_ENV) \
	$(MAKE) \
		-C $(@D)/$(1) \
		CC="$(TARGET_CC)" \
		CXX="$(TARGET_CXX)" \
		$(WPAD_OPENSSL_DRIVER_MAKEOPTS) \
		LIBS="$(WPAD_OPENSSL_TARGET_LDFLAGS)" \
		LIBS_c="$(TARGET_LDFLAGS_C)" \
		AR="$(TARGET_CROSS)gcc-ar" \
		BCHECK= \
		$(2)
endef

define WPAD_OPENSSL_BUILD_CMDS
	echo ` \
		$(call Build/RunMake,hostapd,-s MULTICALL=1 dump_cflags); \
		$(call Build/RunMake,wpa_supplicant,-s MULTICALL=1 dump_cflags) | \
		sed -e 's,-n ,,g' -e 's^$(WPAD_OPENSSL_TARGET_CFLAGS)^^' \
	` > $(@D)/.cflags
	sed -i 's/"/\\"/g' $(@D)/.cflags
	+$(call Build/RunMake,hostapd, \
		CFLAGS="$$(cat $(@D)/.cflags)" \
		MULTICALL=1 \
		hostapd_cli hostapd_multi.a \
	)
	+$(call Build/RunMake,wpa_supplicant, \
		CFLAGS="$$(cat $(@D)/.cflags)" \
		MULTICALL=1 \
		wpa_cli wpa_supplicant_multi.a \
	)
	+$(TARGET_MAKE_ENV) $(TARGET_CC) -o $(@D)/wpad \
		$(WPAD_OPENSSL_TARGET_CFLAGS) \
		$(WPAD_OPENSSL_PKGDIR)/files/multicall.c \
		$(@D)/hostapd/hostapd_multi.a \
		$(@D)/wpa_supplicant/wpa_supplicant_multi.a \
		$(WPAD_OPENSSL_TARGET_LDFLAGS)
endef

define Install/hostapd
	mkdir -p $(1)/usr/sbin
endef

define Install/supplicant
	mkdir -p $(1)/usr/sbin
endef

define Install/wpad
	$(call Install/hostapd,$(1))
	$(call Install/supplicant,$(1))
	$(INSTALL) -D -m 0755 $(@D)/wpad $(1)/usr/sbin/
	ln -sf wpad $(1)/usr/sbin/hostapd
	ln -sf wpad $(1)/usr/sbin/wpa_supplicant
endef

define WPAD_OPENSSL_INSTALL_TARGET_CMDS
	$(call Install/wpad,$(TARGET_DIR))
endef

$(eval $(generic-package))
