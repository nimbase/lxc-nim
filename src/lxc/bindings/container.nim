# Nim bindings for liblxc.
# Container struct with function pointer methods (lxccontainer.h).
#
# (c) 2026 George Lemon | LGPL-2.1-only

import std/posix
import ./common
import ./attach
import ./snapshot

type
  lxc_container* {.importc: "struct lxc_container", header: "<lxc/lxccontainer.h>".} = object
    ## An LXC container handle.
    # private fields
    name*: cstring
    configfile*: cstring
    pidfile*: cstring
    slock*: lxc_lockPtr
    privlock*: lxc_lockPtr
    numthreads*: cint
    lxc_conf*: lxc_confPtr
    # public fields
    error_string*: cstring
    error_num*: cint
    daemonize*: bool
    config_path*: cstring
    # lifecycle
    is_defined*: proc(c: ptr lxc_container): bool {.cdecl.}
    state*: proc(c: ptr lxc_container): cstring {.cdecl.}
    is_running*: proc(c: ptr lxc_container): bool {.cdecl.}
    freeze*: proc(c: ptr lxc_container): bool {.cdecl.}
    unfreeze*: proc(c: ptr lxc_container): bool {.cdecl.}
    init_pid*: proc(c: ptr lxc_container): Pid {.cdecl.}
    load_config*: proc(c: ptr lxc_container, alt_file: cstring): bool {.cdecl.}
    # start / stop
    start*: proc(c: ptr lxc_container, useinit: cint, argv: cstringArray): bool {.cdecl.}
    startl*: pointer  # variadic, skipped
    stop*: proc(c: ptr lxc_container): bool {.cdecl.}
    # daemonize
    want_daemonize*: proc(c: ptr lxc_container, state: bool): bool {.cdecl.}
    want_close_all_fds*: proc(c: ptr lxc_container, state: bool): bool {.cdecl.}
    # config
    config_file_name*: proc(c: ptr lxc_container): cstring {.cdecl.}
    wait*: proc(c: ptr lxc_container, state: cstring, timeout: cint): bool {.cdecl.}
    set_config_item*: proc(c: ptr lxc_container, key: cstring, value: cstring): bool {.cdecl.}
    destroy*: proc(c: ptr lxc_container): bool {.cdecl.}
    save_config*: proc(c: ptr lxc_container, alt_file: cstring): bool {.cdecl.}
    create*: proc(c: ptr lxc_container, t: cstring, bdevtype: cstring, specs: pointer, flags: cint, argv: cstringArray): bool {.cdecl.}
    createl*: pointer  # variadic, skipped
    rename*: proc(c: ptr lxc_container, newname: cstring): bool {.cdecl.}
    reboot*: proc(c: ptr lxc_container): bool {.cdecl.}
    shutdown*: proc(c: ptr lxc_container, timeout: cint): bool {.cdecl.}
    clear_config*: proc(c: ptr lxc_container) {.cdecl.}
    clear_config_item*: proc(c: ptr lxc_container, key: cstring): bool {.cdecl.}
    get_config_item*: proc(c: ptr lxc_container, key: cstring, retv: cstring, inlen: cint): cint {.cdecl.}
    get_running_config_item*: proc(c: ptr lxc_container, key: cstring): cstring {.cdecl.}
    get_keys*: proc(c: ptr lxc_container, key: cstring, retv: cstring, inlen: cint): cint {.cdecl.}
    # networking
    get_interfaces*: proc(c: ptr lxc_container): cstringArray {.cdecl.}
    get_ips*: proc(c: ptr lxc_container, `interface`: cstring, family: cstring, scope: cint): cstringArray {.cdecl.}
    # cgroups
    get_cgroup_item*: proc(c: ptr lxc_container, subsys: cstring, retv: cstring, inlen: cint): cint {.cdecl.}
    set_cgroup_item*: proc(c: ptr lxc_container, subsys: cstring, value: cstring): bool {.cdecl.}
    # config path
    get_config_path*: proc(c: ptr lxc_container): cstring {.cdecl.}
    set_config_path*: proc(c: ptr lxc_container, path: cstring): bool {.cdecl.}
    # clone
    clone*: proc(c: ptr lxc_container, newname: cstring, lxcpath: cstring, flags: cint, bdevtype: cstring, bdevdata: cstring, newsize: uint64, hookargs: cstringArray): ptr lxc_container {.cdecl.}
    # console
    console_getfd*: proc(c: ptr lxc_container, ttynum: ptr cint, ptxfd: ptr cint): cint {.cdecl.}
    console*: proc(c: ptr lxc_container, ttynum: cint, stdinfd: cint, stdoutfd: cint, stderrfd: cint, escape: cint): cint {.cdecl.}
    # attach
    attach*: proc(c: ptr lxc_container, exec_function: lxc_attach_exec_t, exec_payload: pointer, options: ptr lxc_attach_options_t, attached_process: ptr Pid): cint {.cdecl.}
    attach_run_wait*: proc(c: ptr lxc_container, options: ptr lxc_attach_options_t, program: cstring, argv: cstringArray): cint {.cdecl.}
    attach_run_waitl*: pointer  # variadic, skipped
    # snapshots
    snapshot*: proc(c: ptr lxc_container, commentfile: cstring): cint {.cdecl.}
    snapshot_list*: proc(c: ptr lxc_container, snapshots: ptr ptr lxc_snapshot): cint {.cdecl.}
    snapshot_restore*: proc(c: ptr lxc_container, snapname: cstring, newname: cstring): bool {.cdecl.}
    snapshot_destroy*: proc(c: ptr lxc_container, snapname: cstring): bool {.cdecl.}
    # control
    may_control*: proc(c: ptr lxc_container): bool {.cdecl.}
    # devices
    add_device_node*: proc(c: ptr lxc_container, src_path: cstring, dest_path: cstring): bool {.cdecl.}
    remove_device_node*: proc(c: ptr lxc_container, src_path: cstring, dest_path: cstring): bool {.cdecl.}
    # networking (post 1.0)
    attach_interface*: proc(c: ptr lxc_container, dev: cstring, dst_dev: cstring): bool {.cdecl.}
    detach_interface*: proc(c: ptr lxc_container, dev: cstring, dst_dev: cstring): bool {.cdecl.}
    # checkpoint/restore (CRIU)
    checkpoint*: proc(c: ptr lxc_container, directory: cstring, stop: bool, verbose: bool): bool {.cdecl.}
    restore*: proc(c: ptr lxc_container, directory: cstring, verbose: bool): bool {.cdecl.}
    destroy_with_snapshots*: proc(c: ptr lxc_container): bool {.cdecl.}
    snapshot_destroy_all*: proc(c: ptr lxc_container): bool {.cdecl.}
    # migrate
    migrate*: proc(c: ptr lxc_container, cmd: cuint, opts: pointer, size: cuint): cint {.cdecl.}
    # console log
    console_log*: proc(c: ptr lxc_container, log: pointer): cint {.cdecl.}
    # reboot with timeout
    reboot2*: proc(c: ptr lxc_container, timeout: cint): bool {.cdecl.}
    # mount
    mount*: proc(c: ptr lxc_container, source: cstring, target: cstring, filesystemtype: cstring, mountflags: culong, data: pointer, mnt: pointer): cint {.cdecl.}
    umount*: proc(c: ptr lxc_container, target: cstring, mountflags: culong, mnt: pointer): cint {.cdecl.}
    # seccomp
    seccomp_notify_fd*: proc(c: ptr lxc_container): cint {.cdecl.}
    seccomp_notify_fd_active*: proc(c: ptr lxc_container): cint {.cdecl.}
    # pidfd / devpts
    init_pidfd*: proc(c: ptr lxc_container): cint {.cdecl.}
    devpts_fd*: proc(c: ptr lxc_container): cint {.cdecl.}
    # receive timeout (LXC >= 6.0)
    rcv_timeout*: cint
    set_timeout*: proc(c: ptr lxc_container, timeout: cint): bool {.cdecl.}

  lxc_containerPtr* = ptr lxc_container

const
  LXC_CLONE_KEEPNAME* = (1 shl 0)
  LXC_CLONE_KEEPMACADDR* = (1 shl 1)
  LXC_CLONE_SNAPSHOT* = (1 shl 2)
  LXC_CLONE_KEEPBDEVTYPE* = (1 shl 3)
  LXC_CLONE_MAYBE_SNAPSHOT* = (1 shl 4)
  LXC_CLONE_MAXFLAGS* = (1 shl 5)
  LXC_CLONE_ALLOW_RUNNING* = (1 shl 6)

  LXC_CREATE_QUIET* = (1 shl 0)
  LXC_CREATE_MAXFLAGS* = (1 shl 1)
