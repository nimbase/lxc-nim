# config.nim - Read and write container configuration.
#
# Requires root for create/destroy; config read works on existing containers.
#   sudo nim c --path:src -r examples/config.nim

import std/strutils
import ../src/lxc

const
  ContainerName = "example-config"

proc main() =
  var c = newContainer(ContainerName)

  # Clean up any existing test container
  if c.isDefined():
    if c.isRunning(): discard c.stop()
    discard c.destroy()

  echo "Creating container..."
  let ok = c.create(
    t = "download",
    argv = @["--dist", "alpine", "--release", "3.24", "--arch", "amd64"]
  )
  if not ok:
    echo "Failed to create container"
    quit(1)

  echo "=== Setting configuration ==="

  # Set hostname
  discard c.setConfigItem("lxc.uts.name", "config-demo")
  echo "  lxc.uts.name = ", c.getConfigItem("lxc.uts.name")

  # Set rootfs path
  discard c.setConfigItem("lxc.rootfs.path", "dir:/var/lib/lxc/config-demo/rootfs")
  echo "  lxc.rootfs.path = ", c.getConfigItem("lxc.rootfs.path")

  echo ""
  echo "=== Listing config keys (root level) ==="
  let keys = c.getKeys("")
  for line in keys.splitLines():
    let trimmed = line.strip()
    if trimmed.len > 0:
      echo "  ", trimmed

  echo ""
  echo "=== Config file path ==="
  echo "  ", c.configFileName()

  echo ""
  echo "=== Clearing a config item ==="
  discard c.clearConfigItem("lxc.rootfs.path")
  echo "  Cleared lxc.rootfs.path"
  echo "  lxc.rootfs.path = '", c.getConfigItem("lxc.rootfs.path"), "'"

  echo ""
  echo "=== Saving config ==="
  # Save to alternate location to avoid modifying the real config
  let saved = c.saveConfig()
  echo "  saveConfig: ", saved

  # Cleanup
  echo ""
  echo "Destroying container..."
  discard c.destroy()
  echo "Done."

main()
