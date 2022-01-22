LINUX_EXTENSIONS += openwrt-patches

# add dependency

P_LINUX = $(OPENWRT_PATCHES_DIR)/target/linux
P_GENERIC = $(P_LINUX)/generic

extra_tree = $(P_GENERIC)/files
patches = $(P_GENERIC)/backport-5.4 $(P_GENERIC)/pending-5.4 $(P_GENERIC)/hack-5.4

ifeq ($(BR2_LINUX_KERNEL_EXT_OPENWRT_PATCHES_RAMIPS),y)
	P_RAMISP = $(P_LINUX)/ramips

	extra_tree += $(P_RAMISP)/files
	patches += $(P_RAMISP)/patches-5.4
endif

define OPENWRT_PATCHES_PREPARE_KERNEL
	# ensure openwrt-patches unpacked in build dir
	$(MAKE) -C $(BASE_DIR) openwrt-patches; \
	\
	for t in $(extra_tree); do \
		rsync -av $${t}/ $(@D)/ ; \
	done; \
	\
	for p in $(patches); do \
		$(APPLY_PATCHES) $(@D) $${p} '*.patch'  ; \
	done
endef
