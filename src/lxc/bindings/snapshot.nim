# Nim bindings for liblxc.
# Snapshot, bdev_specs, migrate, console log, mount structs (lxccontainer.h).
#
# (c) 2026 George Lemon | LGPL-2.1-only

import std/strutils

const lxcVersionMajor* =
  block:
    var version = 0
    for path in ["/usr/local/include/lxc/version.h",
                 "/usr/include/lxc/version.h"]:
      let output = staticExec(
        "cat " & path & " 2>/dev/null | grep LXC_VERSION_MAJOR | head -1 | awk '{print $3}'")
      let s = output.strip()
      if s.len > 0:
        version = parseInt(s)
        break
    version

type
  lxc_snapshot* {.importc: "struct lxc_snapshot", header: "<lxc/lxccontainer.h>".} = object
    name*: cstring
    comment_pathname*: cstring
    timestamp*: cstring
    lxcpath*: cstring
    free*: proc(s: ptr lxc_snapshot) {.cdecl.}

  bdev_specs_zfs* = object
    zfsroot*: cstring

  bdev_specs_lvm* = object
    vg*: cstring
    lv*: cstring
    thinpool*: cstring

when lxcVersionMajor >= 7:
  type bdev_specs_rbd* = object
    rbdname*: cstring
    rbdpool*: cstring
    rbduser*: cstring
else:
  type bdev_specs_rbd* = object
    rbdname*: cstring
    rbdpool*: cstring

type
  bdev_specs* {.importc: "struct bdev_specs", header: "<lxc/lxccontainer.h>".} = object
    fstype*: cstring
    fssize*: uint64
    zfs*: bdev_specs_zfs
    lvm*: bdev_specs_lvm
    dir*: cstring
    rbd*: bdev_specs_rbd

  lxc_mount* {.importc: "struct lxc_mount", header: "<lxc/lxccontainer.h>".} = object
    version*: cint

  lxc_console_log* {.importc: "struct lxc_console_log", header: "<lxc/lxccontainer.h>".} = object
    clear*: bool
    read*: bool
    read_max*: ptr uint64
    data*: cstring

  migrate_opts* {.importc: "struct migrate_opts", header: "<lxc/lxccontainer.h>".} = object
    directory*: cstring
    verbose*: bool
    stop*: bool
    predump_dir*: cstring
    pageserver_address*: cstring
    pageserver_port*: cstring
    preserves_inodes*: bool
    action_script*: cstring
    disable_skip_in_flight*: bool
    ghost_limit*: uint64
    features_to_check*: uint64

  lxc_log* {.importc: "struct lxc_log", header: "<lxc/lxccontainer.h>".} = object
    name*: cstring
    lxcpath*: cstring
    file*: cstring
    level*: cstring
    prefix*: cstring
    quiet*: bool

const
  MIGRATE_PRE_DUMP* = 0
  MIGRATE_DUMP* = 1
  MIGRATE_RESTORE* = 2
  MIGRATE_FEATURE_CHECK* = 3

  FEATURE_MEM_TRACK* = (1'u64 shl 0)
  FEATURE_LAZY_PAGES* = (1'u64 shl 1)

  LXC_MOUNT_API_V1* = 1
