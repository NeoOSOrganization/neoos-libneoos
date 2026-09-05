# NeoOS-native libc alternative to musl -- see README.md and
# docs/superpowers/specs/2026-09-05-embedded-test-and-app-architecture.md
# in neoos-kernel for why this exists beside musl.
#
# Needs nothing from neoos-kernel to build: syscall numbers are
# NeoOS's own and are #define'd directly in src/syscall.c, not
# generated from or shared with kernel headers.
CC := x86_64-elf-gcc
AS := nasm
ASFLAGS := -f elf64

# Exact match to the monorepo's USER_CFLAGS (Makefile), since a
# mismatch here would silently produce ABI-incompatible binaries:
# programs link at 0x200000000000 (-mcmodel=large is not optional),
# and NeoOS's TLS model/calling convention depend on the rest.
CFLAGS := -ffreestanding -fno-stack-protector -mno-red-zone -msse3 -mssse3 \
	-msse4.1 -msse4.2 -mcmodel=large -fno-pic -ftls-model=local-exec \
	-static -nostdlib -Wall -Wextra -std=gnu11 -O2 -Iinclude

PREFIX ?= build-output
SRCS := $(wildcard src/*.c)
OBJS := $(patsubst src/%.c,build/obj/%.o,$(SRCS))

.PHONY: all clean
all: $(PREFIX)/lib/libneoos.a $(PREFIX)/lib/crt0.o $(PREFIX)/include

build/obj/%.o: src/%.c
	@mkdir -p build/obj
	$(CC) $(CFLAGS) -c $< -o $@

build/obj/crt0.o: src/crt0.asm
	@mkdir -p build/obj
	$(AS) $(ASFLAGS) src/crt0.asm -o $@

$(PREFIX)/lib/libneoos.a: $(OBJS)
	@mkdir -p $(PREFIX)/lib
	ar rcs $@ $(OBJS)

$(PREFIX)/lib/crt0.o: build/obj/crt0.o
	@mkdir -p $(PREFIX)/lib
	cp build/obj/crt0.o $@

$(PREFIX)/include: include
	@mkdir -p $(PREFIX)
	rm -rf $(PREFIX)/include
	cp -r include $(PREFIX)/include

clean:
	rm -rf build $(PREFIX)
