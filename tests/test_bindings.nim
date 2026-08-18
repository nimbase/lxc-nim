# Tests for the thin bindings layer.
# Validates type definitions, constants, and function signatures compile correctly.
#
# (c) 2026 George Lemon | LGPL-2.1-only

import unittest
import lxc
import lxc/bindings/[common, container, attach, snapshot, free_api]

# ------------------------------------------------------------------
# common.nim
# ------------------------------------------------------------------

suite "common.nim - platform constants":
  test "ext is a valid shared library extension":
    check ext.len > 0
    check ext in ["so", "dll", "dylib"]

# ------------------------------------------------------------------
# attach.nim
# ------------------------------------------------------------------

suite "attach.nim - env policy enum":
  test "LXC_ATTACH_KEEP_ENV is 0":
    check ord(LXC_ATTACH_KEEP_ENV) == 0

  test "LXC_ATTACH_CLEAR_ENV is 1":
    check ord(LXC_ATTACH_CLEAR_ENV) == 1

suite "attach.nim - attach flags":
  test "LXC_ATTACH_MOVE_TO_CGROUP":
    check LXC_ATTACH_MOVE_TO_CGROUP == 0x00000001

  test "LXC_ATTACH_DROP_CAPABILITIES":
    check LXC_ATTACH_DROP_CAPABILITIES == 0x00000002

  test "LXC_ATTACH_SET_PERSONALITY":
    check LXC_ATTACH_SET_PERSONALITY == 0x00000004

  test "LXC_ATTACH_LSM_EXEC":
    check LXC_ATTACH_LSM_EXEC == 0x00000008

  test "LXC_ATTACH_REMOUNT_PROC_SYS":
    check LXC_ATTACH_REMOUNT_PROC_SYS == 0x00010000

  test "LXC_ATTACH_LSM_NOW":
    check LXC_ATTACH_LSM_NOW == 0x00020000

  test "LXC_ATTACH_NO_NEW_PRIVS":
    check LXC_ATTACH_NO_NEW_PRIVS == 0x00040000

  test "LXC_ATTACH_TERMINAL":
    check LXC_ATTACH_TERMINAL == 0x00080000

  test "LXC_ATTACH_LSM_LABEL":
    check LXC_ATTACH_LSM_LABEL == 0x00100000

  test "LXC_ATTACH_SETGROUPS":
    check LXC_ATTACH_SETGROUPS == 0x00200000

  test "LXC_ATTACH_DEFAULT":
    check LXC_ATTACH_DEFAULT == 0x0000FFFF

  test "LXC_ATTACH_LSM is combination of LSM flags":
    check LXC_ATTACH_LSM == (LXC_ATTACH_LSM_EXEC or LXC_ATTACH_LSM_NOW or LXC_ATTACH_LSM_LABEL)

suite "attach.nim - attach options struct":
  test "lxc_attach_options_t has expected fields":
    var opts: lxc_attach_options_t
    opts.attach_flags = LXC_ATTACH_DEFAULT
    opts.namespaces = -1
    opts.personality = LXC_ATTACH_DETECT_PERSONALITY
    opts.initial_cwd = nil
    opts.stdin_fd = 0
    opts.stdout_fd = 1
    opts.stderr_fd = 2
    opts.log_fd = -1
    opts.lsm_label = nil
    check opts.attach_flags == LXC_ATTACH_DEFAULT
    check opts.stdin_fd == 0
    check opts.stdout_fd == 1
    check opts.stderr_fd == 2
    check opts.log_fd == -1

suite "attach.nim - attach command struct":
  test "lxc_attach_command_t has program and argv":
    var cmd: lxc_attach_command_t
    cmd.program = "/bin/sh"
    cmd.argv = nil
    check cmd.program == "/bin/sh"

# ------------------------------------------------------------------
# snapshot.nim
# ------------------------------------------------------------------

suite "snapshot.nim - migrate constants":
  test "MIGRATE_PRE_DUMP is 0":
    check MIGRATE_PRE_DUMP == 0

  test "MIGRATE_DUMP is 1":
    check MIGRATE_DUMP == 1

  test "MIGRATE_RESTORE is 2":
    check MIGRATE_RESTORE == 2

  test "MIGRATE_FEATURE_CHECK is 3":
    check MIGRATE_FEATURE_CHECK == 3

suite "snapshot.nim - feature flags":
  test "FEATURE_MEM_TRACK":
    check FEATURE_MEM_TRACK == (1'u64 shl 0)

  test "FEATURE_LAZY_PAGES":
    check FEATURE_LAZY_PAGES == (1'u64 shl 1)

suite "snapshot.nim - LXC_MOUNT_API_V1":
  test "LXC_MOUNT_API_V1 is 1":
    check LXC_MOUNT_API_V1 == 1

suite "snapshot.nim - lxc_snapshot struct":
  test "lxc_snapshot has expected fields":
    var snap: lxc_snapshot
    snap.name = "test-snap"
    snap.comment_pathname = nil
    snap.timestamp = "2026-01-01"
    snap.lxcpath = "/var/lib/lxc"
    snap.free = nil
    check snap.name == "test-snap"
    check snap.timestamp == "2026-01-01"
    check snap.lxcpath == "/var/lib/lxc"

suite "snapshot.nim - migrate_opts struct":
  test "migrate_opts has expected fields":
    var opts: migrate_opts
    opts.directory = "/tmp/dump"
    opts.verbose = true
    opts.stop = false
    opts.predump_dir = "predump"
    opts.pageserver_address = "127.0.0.1"
    opts.pageserver_port = "9000"
    opts.preserves_inodes = true
    opts.action_script = nil
    opts.disable_skip_in_flight = false
    opts.ghost_limit = 1024 * 1024
    opts.features_to_check = FEATURE_MEM_TRACK
    check opts.directory == "/tmp/dump"
    check opts.verbose == true
    check opts.stop == false
    check opts.ghost_limit == 1048576

suite "snapshot.nim - lxc_console_log struct":
  test "lxc_console_log has expected fields":
    var log: lxc_console_log
    log.clear = false
    log.read = true
    log.read_max = nil
    log.data = nil
    check log.clear == false
    check log.read == true

suite "snapshot.nim - lxc_mount struct":
  test "lxc_mount has version field":
    var mnt: lxc_mount
    mnt.version = LXC_MOUNT_API_V1
    check mnt.version == LXC_MOUNT_API_V1

suite "snapshot.nim - lxc_log struct":
  test "lxc_log has expected fields":
    var log: lxc_log
    log.name = "test"
    log.lxcpath = "/var/lib/lxc"
    log.file = nil
    log.level = "DEBUG"
    log.prefix = "test"
    log.quiet = false
    check log.name == "test"
    check log.level == "DEBUG"
    check log.quiet == false

suite "snapshot.nim - bdev_specs struct":
  test "bdev_specs has expected fields":
    var specs: bdev_specs
    specs.fstype = "ext4"
    specs.fssize = 1024 * 1024 * 1024
    specs.zfs.zfsroot = nil
    specs.lvm.vg = nil
    specs.lvm.lv = nil
    specs.lvm.thinpool = nil
    specs.dir = "/var/lib/lxc"
    specs.rbd.rbdname = nil
    specs.rbd.rbdpool = nil
    specs.rbd.rbduser = nil
    check specs.fstype == "ext4"
    check specs.fssize == 1073741824
    check specs.dir == "/var/lib/lxc"

# ------------------------------------------------------------------
# container.nim
# ------------------------------------------------------------------

suite "container.nim - struct field access":
  test "lxc_container has name field":
    # Just verify the field exists and is accessible
    check compiles(block:
      var c: lxc_container
      discard c.name)

  test "lxc_container has error_string field":
    check compiles(block:
      var c: lxc_container
      discard c.error_string)

  test "lxc_container has error_num field":
    check compiles(block:
      var c: lxc_container
      discard c.error_num)

  test "lxc_container has daemonize field":
    check compiles(block:
      var c: lxc_container
      discard c.daemonize)

  test "lxc_container has config_path field":
    check compiles(block:
      var c: lxc_container
      discard c.config_path)

  test "lxc_container has rcv_timeout field":
    check compiles(block:
      var c: lxc_container
      discard c.rcv_timeout)

suite "container.nim - function pointer fields":
  test "is_defined function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.is_defined)

  test "state function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.state)

  test "is_running function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.is_running)

  test "freeze function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.freeze)

  test "unfreeze function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.unfreeze)

  test "init_pid function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.init_pid)

  test "init_pidfd function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.init_pidfd)

  test "load_config function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.load_config)

  test "start function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.start)

  test "stop function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.stop)

  test "want_daemonize function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.want_daemonize)

  test "want_close_all_fds function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.want_close_all_fds)

  test "config_file_name function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.config_file_name)

  test "wait function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.wait)

  test "set_config_item function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.set_config_item)

  test "destroy function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.destroy)

  test "save_config function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.save_config)

  test "create function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.create)

  test "rename function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.rename)

  test "reboot function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.reboot)

  test "shutdown function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.shutdown)

  test "clear_config function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.clear_config)

  test "clear_config_item function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.clear_config_item)

  test "get_config_item function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.get_config_item)

  test "get_running_config_item function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.get_running_config_item)

  test "get_keys function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.get_keys)

  test "get_interfaces function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.get_interfaces)

  test "get_ips function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.get_ips)

  test "get_cgroup_item function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.get_cgroup_item)

  test "set_cgroup_item function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.set_cgroup_item)

  test "get_config_path function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.get_config_path)

  test "set_config_path function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.set_config_path)

  test "clone function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.clone)

  test "console_getfd function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.console_getfd)

  test "console function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.console)

  test "attach function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.attach)

  test "attach_run_wait function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.attach_run_wait)

  test "snapshot function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.snapshot)

  test "snapshot_list function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.snapshot_list)

  test "snapshot_restore function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.snapshot_restore)

  test "snapshot_destroy function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.snapshot_destroy)

  test "may_control function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.may_control)

  test "add_device_node function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.add_device_node)

  test "remove_device_node function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.remove_device_node)

  test "attach_interface function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.attach_interface)

  test "detach_interface function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.detach_interface)

  test "checkpoint function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.checkpoint)

  test "restore function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.restore)

  test "destroy_with_snapshots function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.destroy_with_snapshots)

  test "snapshot_destroy_all function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.snapshot_destroy_all)

  test "migrate function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.migrate)

  test "console_log function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.console_log)

  test "reboot2 function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.reboot2)

  test "mount function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.mount)

  test "umount function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.umount)

  test "seccomp_notify_fd function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.seccomp_notify_fd)

  test "seccomp_notify_fd_active function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.seccomp_notify_fd_active)

  test "devpts_fd function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.devpts_fd)

  test "set_timeout function pointer signature":
    check compiles(block:
      var c: lxc_container
      discard c.set_timeout)

# ------------------------------------------------------------------
# free_api.nim
# ------------------------------------------------------------------

suite "free_api.nim - function signatures":
  test "lxc_container_new signature":
    check compiles(lxc_container_new(nil, nil))

  test "lxc_container_get signature":
    check compiles(block:
      var c: lxc_containerPtr = nil
      discard lxc_container_get(c))

  test "lxc_container_put signature":
    check compiles(block:
      var c: lxc_containerPtr = nil
      discard lxc_container_put(c))

  test "lxc_get_version signature":
    check compiles(lxc_get_version())

  test "lxc_get_global_config_item signature":
    check compiles(lxc_get_global_config_item("lxc.lxcpath"))

  test "lxc_get_wait_states signature":
    check compiles(lxc_get_wait_states(nil))

  test "lxc_config_item_is_supported signature":
    check compiles(lxc_config_item_is_supported("lxc.lxcpath"))

  test "lxc_has_api_extension signature":
    check compiles(lxc_has_api_extension("nesting"))

  test "list_defined_containers signature":
    check compiles(list_defined_containers(nil, nil, nil))

  test "list_active_containers signature":
    check compiles(list_active_containers(nil, nil, nil))

  test "list_all_containers signature":
    check compiles(list_all_containers(nil, nil, nil))

  test "lxc_log_init signature":
    check compiles(block:
      var log: lxc_log
      discard lxc_log_init(addr log))

  test "lxc_log_close signature":
    check compiles(lxc_log_close())

  test "lxc_attach_run_command signature":
    check compiles(block:
      var cmd: lxc_attach_command_t
      discard lxc_attach_run_command(addr cmd))

  test "lxc_attach_run_shell signature":
    check compiles(lxc_attach_run_shell(nil))
