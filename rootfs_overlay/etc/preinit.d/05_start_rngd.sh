#!/bin/sh

# There's a call to getrandom(2) when loading the crypto NIF. Currently, it's
# loaded before nerves_runtime can start rngd and provide sufficient entropy to
# the kernel. This means genrandom(2) blocks the BEAM, and it can block the it
# sufficiently long to trigger a hardware watchdog to reboot. The workaround is
# to start rngd here.
/usr/sbin/rngd
