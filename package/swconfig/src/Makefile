ifndef CFLAGS
CFLAGS = -O2 -g -I. -I$(STAGING_DIR)/usr/include/libnl3 -I$(STAGING_DIR)/usr/include/libubox
endif
LIBS=-lnl-3 -lnl-genl-3

all: swconfig

%.o: %.c
	$(CC) $(CFLAGS) -fPIC -c -o $@ $^

swconfig: swlib.o cli.o uci.o
	$(CC) $(LDFLAGS) -o $@ $^ -L$(STAGING_DIR)/usr/lib $(LIBS)
