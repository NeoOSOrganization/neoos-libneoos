# neoos-libneoos

The NeoOS-native libc alternative to musl: `crt0.o`, syscall wrappers
(NeoOS's own numbers, no shim needed), and headers for programs that
don't need POSIX/musl's full surface.

Extracted from the NeoOS monorepo
(https://github.com/Neo-vortex/NeoOS)'s `lib/` directory as part of the
[embedded test and app architecture](https://github.com/NeoOSOrganization/neoos-kernel/blob/main/docs/superpowers/specs/2026-09-05-embedded-test-and-app-architecture.md).

## Build

```sh
make
# Produces: build-output/lib/libneoos.a, build-output/lib/crt0.o,
#           build-output/include/
```

Needs `x86_64-elf-gcc` and `nasm` on `PATH` (see
[neoos-kernel](https://github.com/NeoOSOrganization/neoos-kernel)'s
`toolchain/build.sh`). Nothing from neoos-kernel is required at build
time — NeoOS's syscall numbers are `#define`d directly in
`src/syscall.c`, not generated from or shared with kernel headers.

## Using it

```sh
$(CC) -mcmodel=large -fno-pic -mno-red-zone -static -nostdlib \
    -Ipath/to/build-output/include \
    -T user.ld -o prog.elf \
    path/to/build-output/lib/crt0.o prog.c \
    -Lpath/to/build-output/lib -lneoos
```

`-mcmodel=large` is not optional: NeoOS programs link at
`0x200000000000`.

## Related repositories

- [neoos-kernel](https://github.com/NeoOSOrganization/neoos-kernel) — the kernel
- [neoos-musl](https://github.com/NeoOSOrganization/neoos-musl) — musl libc, for programs that need it instead
- [neoos-kernel-tests-common](https://github.com/NeoOSOrganization/neoos-kernel-tests-common) — the regression suite, built against this
