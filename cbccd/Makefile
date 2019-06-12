
CBCCD_OBJS=cbccd.o cbccd_cmd.o cbccd_device.o cbccd_pgsql.o cbccd_mon.o cbccd_config.o cbccd_admin.o cbccd_report.o cbccd_wapi.o
CBCCD_DST=cbccd
CBCCD_CFLAGS=$(CFLAGS) -I../cbcc-common/ -I../cbcc-util/ -I/usr/include/pgsql/
CBCCD_LIBS=$(LIBS) -L../cbcc-util -lcbcc_util -lpq
CBCCD_CONF_DIR=./etc/cm

all: $(CBCCD_OBJS)

$(CBCCD_DST): $(CBCCD_OBJS)
	$(CC) $(CBCCD_CFLAGS) $(CBCCD_LIBS) -o $(CBCCD_DST) $(CBCCD_OBJS)

.c.o:
	$(CC) $(CBCCD_CFLAGS) -c -o $@ $<
	
clean:
	rm -rf $(CBCCD_DST) $(CBCCD_OBJS)

install: $(CBCCD_DST) $(CBCCD_WAPI_CLIENT_DST)
	install -d $(DESTDIR)/$(CBCC_INST_DIR)/sbin
	install -D -m755 $(CBCCD_DST) $(DESTDIR)/$(CBCC_INST_DIR)/sbin/

uninstall:
	rm -rf $(DESTDIR)/$(CBCC_INST_DIR)/sbin/$(CBCCD_DST)
