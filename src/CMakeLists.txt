#
# CMake script for the OS library
#
add_definitions(-DARCH_${ARCH})
add_definitions(-DARCH="${ARCH}")
if (NOT threading)
add_definitions(-DINCLUDEOS_SINGLE_THREADED)
endif()

include_directories(${LIBCXX_INCLUDE_DIR})
include_directories(${MUSL_INCLUDE_DIR})
include_directories(${SOLO5_INCLUDE_DIR})
include_directories(${INCLUDEOS_ROOT}/src/include)
include_directories(${INCLUDEOS_ROOT}/api)
include_directories(${INCLUDEOS_ROOT}/mod/)
include_directories(${INCLUDEOS_ROOT}/mod/GSL/)
include_directories(${INCLUDEOS_ROOT}/mod/rapidjson/include)
include_directories(${INCLUDEOS_ROOT}/mod/uzlib/src) # tinf.h for tar
include_directories(${BOTAN_DIR})
include_directories(${OPENSSL_DIR}/include)
if(${ARCH} STREQUAL "x86_64")
  set(OPENSSL_MODULES "net/openssl/init.cpp" "net/openssl/client.cpp"
                      "net/openssl/server.cpp"
                      "net/https/openssl_server.cpp" "net/http/client.cpp")
  set(OPENSSL_LIBS    openssl_ssl openssl_crypto)
endif()
set(BOTAN_MODULES "net/https/botan_server.cpp")

set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)

### x86_64 arch specific ###
set(ARCH_OBJECTS
    arch/${ARCH}/apic_asm.asm
    arch/${ARCH}/apic_longmode.asm
    arch/${ARCH}/arch_start.asm
    arch/${ARCH}/exceptions.asm
    arch/${ARCH}/interrupts.asm
    arch/${ARCH}/fiber_asm.asm
    arch/${ARCH}/__syscall_entry.asm
    arch/${ARCH}/syscall_entry.cpp
    arch/${ARCH}/ist.cpp
    arch/${ARCH}/paging.cpp
    arch/${ARCH}/init_paging.cpp
)

### x86 PC specific ###
set(X86_PC_OBJECTS
    platform/x86_pc/start.asm
    platform/x86_pc/kernel_start.cpp
    platform/x86_pc/platform.cpp
    platform/x86_pc/os.cpp
    platform/x86_pc/clocks.cpp
    platform/x86_pc/cmos.cpp
    platform/x86_pc/cmos_clock.cpp
    platform/x86_pc/gdt.cpp
    platform/x86_pc/acpi.cpp
    platform/x86_pc/ioapic.cpp
    platform/x86_pc/apic.cpp
    platform/x86_pc/apic_timer.cpp
    platform/x86_pc/apic_revenant.cpp
    platform/x86_pc/smp.cpp
    platform/x86_pc/pit.cpp
    platform/x86_pc/cpu_freq_sampling.cpp
    platform/x86_pc/serial1.cpp
    platform/x86_pc/pic.cpp
    platform/x86_pc/softreset.cpp
    platform/x86_pc/sanity_checks.cpp
    platform/x86_pc/smbios.cpp
    platform/x86_pc/idt.cpp
    platform/x86_pc/../kvm/kvmclock.cpp
    platform/x86_pc/../kvm/pv_eoi.cpp
)

## Musl ##
set(MUSL_OBJECTS
    musl/futex.cpp musl/close.cpp musl/fcntl.cpp musl/lseek.cpp musl/ioctl.cpp musl/writev.cpp
    musl/write.cpp musl/brk.cpp musl/madvise.cpp musl/mmap.cpp musl/mremap.cpp musl/munmap.cpp
    musl/lseek.cpp musl/sched_getaffinity.cpp musl/sysinfo.cpp musl/prlimit64.cpp
    musl/getrlimit.cpp musl/sched_yield.cpp musl/set_robust_list.cpp
    musl/nanosleep.cpp musl/open.cpp musl/creat.cpp musl/clock_gettime.cpp musl/gettimeofday.cpp
    musl/poll.cpp musl/exit.cpp musl/close.cpp musl/set_tid_address.cpp
    musl/pipe.cpp musl/read.cpp musl/readv.cpp musl/getpid.cpp musl/getuid.cpp musl/mknod.cpp musl/sync.cpp
    musl/msync.cpp musl/mincore.cpp musl/syscall_n.cpp musl/sigmask.cpp musl/gettid.cpp
    musl/socketcall.cpp musl/rt_sigaction.cpp
    musl/stat.cpp musl/fstat.cpp musl/fstatat.cpp
    musl/access.cpp
    musl/chmod.cpp
    musl/chown.cpp
    musl/cwd.cpp
    musl/dup3.cpp # also dup, dup2
    musl/execve.cpp
    musl/fchmod.cpp
    musl/fchmodat.cpp
    musl/fchown.cpp
    musl/fsync.cpp
    musl/ftruncate.cpp
    musl/getdents.cpp
    musl/geteuid.cpp
    musl/getgid.cpp
    musl/getuid.cpp
    musl/kill.cpp
    musl/mkdir.cpp
    musl/mkdirat.cpp
    musl/mknodat.cpp
    musl/openat.cpp
    musl/readlink.cpp
    musl/rename.cpp
    musl/rmdir.cpp
    musl/select.cpp
    musl/setgid.cpp
    musl/setpgid.cpp
    musl/setrlimit.cpp
    musl/setsid.cpp
    musl/setuid.cpp
    musl/wait4.cpp
    musl/umask.cpp
    musl/uname.cpp
    musl/utimensat.cpp
    musl/unlink.cpp
)

## Drivers ##
set(DRIVER_OBJECTS
    drivers/bootlog.cpp
    drivers/default_stdout.cpp
    drivers/heap_debugging.cpp
    drivers/vga_emergency.cpp
    drivers/vgaout.cpp
)
set(OS_OBJECTS
  kernel/multiboot.cpp
  kernel/syscalls.cpp kernel/os.cpp kernel/cpuid.cpp kernel/block.cpp
  kernel/events.cpp kernel/memmap.cpp kernel/pci_manager.cpp
  kernel/heap.cpp kernel/service_stub.cpp kernel/elf.cpp
  kernel/vga.cpp kernel/context.cpp kernel/context_asm.asm
  kernel/fiber.cpp kernel/tls.cpp kernel/profile.cpp kernel/scoped_profiler.cpp
  kernel/terminal.cpp kernel/timers.cpp kernel/rtc.cpp kernel/rng.cpp
  kernel/system_log.cpp kernel/rdrand.cpp kernel/solo5_manager.cpp
  util/memstream.c util/async.cpp util/statman.cpp util/logger.cpp util/sha1.cpp
  util/syslog_facility.cpp util/syslogd.cpp util/uri.cpp util/percent_encoding.cpp
  util/tar.cpp util/path_to_regex.cpp util/config.cpp util/autoconf.cpp util/crc32.cpp
  crt/c_abi.c crt/ctype_b_loc.c crt/ctype_tolower_loc.c crt/string.c
  crt/quick_exit.cpp crt/cxx_abi.cpp
  hw/pci_device.cpp hw/nic.cpp hw/ps2.cpp hw/serial.cpp hw/vga_gfx.cpp
  hw/msi.cpp hw/pci_msi.cpp virtio/virtio.cpp virtio/virtio_queue.cpp
  net/ethernet/ethernet.cpp net/ethernet/ethernet_8021q.cpp
  net/checksum.cpp net/ip4/arp.cpp net/ip4/ip4.cpp net/ip4/reassembly.cpp
  net/tcp/tcp.cpp net/tcp/connection.cpp net/tcp/connection_states.cpp
  net/tcp/write_queue.cpp net/tcp/rttm.cpp net/tcp/listener.cpp
  net/tcp/read_buffer.cpp net/tcp/read_request.cpp net/tcp/stream.cpp
  net/ip4/icmp4.cpp net/ip4/udp.cpp net/ip4/udp_socket.cpp
  net/ip6/ip6.cpp net/ip6/icmp6.cpp net/ip6/ndp.cpp
  net/dns/dns.cpp net/dns/client.cpp net/dhcp/dh4client.cpp net/dhcp/dhcpd.cpp
  net/buffer_store.cpp net/inet.cpp
  net/super_stack.cpp net/configure.cpp net/conntrack.cpp net/vlan_manager.cpp
  net/http/header.cpp net/http/header_fields.cpp net/http/message.cpp net/http/request.cpp
  net/http/response.cpp net/http/status_codes.cpp net/http/time.cpp net/http/version.cpp
  net/http/mime_types.cpp net/http/cookie.cpp
  net/http/client_connection.cpp net/http/basic_client.cpp
  net/http/server_connection.cpp net/http/server.cpp net/http/response_writer.cpp
  net/ws/websocket.cpp ${OPENSSL_MODULES} ${BOTAN_MODULES}
  net/nat/nat.cpp net/nat/napt.cpp
  fs/disk.cpp fs/filesystem.cpp fs/dirent.cpp fs/mbr.cpp fs/path.cpp
  fs/fat.cpp fs/fat_async.cpp fs/fat_sync.cpp fs/memdisk.cpp
  # POSIX
  posix/fd.cpp posix/file_fd.cpp posix/tcp_fd.cpp posix/udp_fd.cpp posix/unix_fd.cpp

  ${ARCH_OBJECTS}
  ${X86_PC_OBJECTS}
  ${MUSL_OBJECTS}
  ${DRIVER_OBJECTS}
)

add_library(os STATIC ${OS_OBJECTS})
add_dependencies(os PrecompiledLibraries botan ${OPENSSL_LIBS})
set_target_properties(os PROPERTIES LINKER_LANGUAGE CXX)

# disable sanitizers on c_abi and cxx_abi, etc.
set_source_files_properties(crt/c_abi.c PROPERTIES COMPILE_FLAGS "-fno-sanitize=all")
set_source_files_properties(crt/cxx_abi.cpp PROPERTIES COMPILE_FLAGS "-fno-sanitize=all")
set_source_files_properties(platform/x86_pc/kernel_start.cpp PROPERTIES COMPILE_FLAGS "-fno-sanitize=all")
set_source_files_properties(platform/x86_pc/serial1.cpp PROPERTIES COMPILE_FLAGS "-fno-sanitize=all")

#
# Installation
#
set(CMAKE_INSTALL_MESSAGE LAZY) # to avoid spam
install(TARGETS os DESTINATION includeos/${ARCH}/lib)

install(DIRECTORY ${INCLUDEOS_ROOT}/src/memdisk/ DESTINATION includeos/memdisk
        FILES_MATCHING PATTERN "*.*")

install(FILES service_name.cpp DESTINATION includeos/src)
