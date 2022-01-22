include $(sort $(wildcard $(NERVES_DEFCONFIG_DIR)/package/*/*.mk))

# not work, need manual install openwrt-patches package
include $(NERVES_DEFCONFIG_DIR)/linux/linux-ext-openwrt-patches.mk


