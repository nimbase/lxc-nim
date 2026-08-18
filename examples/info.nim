# info.nim - Display LXC library information and capabilities.
#
# Works without root (read-only):
#   nim c --path:src -r examples/info.nim

import std/strutils
import ../src/lxc

proc main() =
  echo "=== LXC Library Information ==="
  echo ""
  echo "Version:    ", lxcVersion()
  echo "lxcpath:    ", lxcGlobalConfigItem("lxc.lxcpath")
  echo "rootfs:     ", lxcGlobalConfigItem("lxc.lxc.rootfs.path")

  echo ""
  echo "=== Supported config items ==="
  for key in ["lxc.lxcpath", "lxc.lxc.rootfs.path", "lxc.bdev.lvm.vg",
              "lxc.bdev.zfs.pool", "lxc.apparmor.profile"]:
    let supported = lxcConfigItemIsSupported(key)
    echo "  ", key, ": ", supported

  echo ""
  echo "=== API extensions ==="
  for ext in ["seccomp", "cgroup2", "mount", "criu", "stacking",
              "pidfd", "devpts_fd", "set_timeout"]:
    let has = lxcHasApiExtension(ext)
    echo "  ", ext, ": ", has

  echo ""
  echo "=== Container states ==="
  let states = lxcGetWaitStates()
  echo "  ", states.join(", ")

  echo ""
  echo "=== Existing containers ==="
  let all = listAllContainers()
  echo "  Total: ", all.len

main()
