# Makefile for CBCC

export MAKE = make
export CC = gcc
export CFLAGS += --std=gnu99 -Wall -pedantic -Wextra -Wformat-nonliteral -Wformat-security -Winit-self \
		 -Wswitch-default -Wunused-parameter -Wundef -Wunsafe-loop-optimizations -Wbad-function-cast -Wcast-qual -Wwrite-strings \
		 -Wlogical-op -fmessage-length=0

export CBCC_INST_DIR = /usr

export LIBS += -lpthread -ljson -lcrypto -lssl

all: build-util build-cbccd
test: build-test-pgsql

build-util:
	$(MAKE) -C cbcc-util
	
build-cbccd: build-util
	$(MAKE) -C cbccd
	
build-test-pgsql:
	$(MAKE) -C tests/pgsql_test
	
clean:
	$(MAKE) -C cbcc-util clean
	$(MAKE) -C cbccd clean
	$(MAKE) -C tests/pgsql_test clean

install:
	$(MAKE) -C cbcc-util install
	$(MAKE) -C cbccd install

uninstall:
	$(MAKE) -C cbcc-util uninstall
	$(MAKE) -C cbccd uninstall
