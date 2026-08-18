# list_containers.nim - List all defined and running containers.
#
# Works without root (read-only):
#   nim c --path:src -r examples/list_containers.nim

import ../src/lxc

proc main() =
  echo "LXC version: ", lxcVersion()
  echo ""

  echo "=== Global config ==="
  echo "  lxc.lxcpath: ", lxcGlobalConfigItem("lxc.lxcpath")
  echo ""

  echo "=== Defined containers ==="
  let defined = listDefinedContainers()
  if defined.len == 0:
    echo "  (none)"
  for c in defined:
    echo "  - ", c.Handle.name
    echo "    state: ", c.state()
    echo "    running: ", c.isRunning()

  echo ""
  echo "=== Running containers ==="
  let active = listActiveContainers()
  if active.len == 0:
    echo "  (none)"
  for c in active:
    echo "  - ", c.Handle.name
    echo "    state: ", c.state()
    echo "    PID: ", c.initPid()

  echo ""
  echo "=== All containers ==="
  let all = listAllContainers()
  echo "  Total: ", all.len

main()
