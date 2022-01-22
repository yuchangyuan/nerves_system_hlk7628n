################################################################################
#
# lzma-old
#
################################################################################

LZMA_OLD_VERSION = 4.32.7
LZMA_OLD_SOURCE = lzma-$(LZMA_VERSION).tar.xz
LZMA_OLD_SITE = http://tukaani.org/lzma
LZMA_OLD_LICENSE = LGPL-2.1+ (lzmadec library, lzmainfo, LzmaDecode), GPL-2.0+ (lzma program, lzgrep and lzmore scripts), GPL-3.0+ (tests)
LZMA_OLD_LICENSE_FILES = COPYING.GPLv2 COPYING.GPLv3 COPYING.LGPLv2.1

# not work without 'HOST_' prefix
HOST_LZMA_OLD_CONF_OPTS = --program-suffix=-old

$(eval $(host-autotools-package))

