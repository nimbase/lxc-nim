# snapshots.nim - Create, list, restore, and destroy snapshots.
#
# Requires root: sudo nim c --path:src -r examples/snapshots.nim

import std/os
import ../src/lxc

const
  ContainerName = "example-snapshots"

proc main() =
  var c = newContainer(ContainerName)

  # Clean up
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

  # Disable networking (no lxcbr0 bridge on this host)
  discard c.setConfigItem("lxc.net.0.type", "empty")
  discard c.saveConfig()

  echo "Starting container briefly..."
  discard c.start()
  discard c.wait("RUNNING", 30)
  sleep(1000)  # let it initialize

  echo "Stopping container for snapshot..."
  discard c.stop()
  discard c.wait("STOPPED", 30)

  echo ""
  echo "=== Creating snapshot 'snap0' ==="
  let snapNum = c.snapshot()
  echo "  Snapshot number: ", snapNum

  echo ""
  echo "=== Listing snapshots ==="
  let snaps = c.snapshotList()
  for s in snaps:
    echo "  - name: ", $s.name
    echo "    timestamp: ", $s.timestamp
    echo "    comment: ", $s.comment_pathname

  echo ""
  echo "=== Restoring snapshot 'snap0' as 'restored-ct' ==="
  let restored = c.snapshotRestore("snap0", "restored-ct")
  echo "  Restored: ", restored

  var rc = newContainer("restored-ct")
  if rc.isDefined():
    echo "  Restored container state: ", rc.state()

  echo ""
  echo "=== Destroying snapshot ==="
  discard c.snapshotDestroy("snap0")
  echo "  Snapshot destroyed"

  let remaining = c.snapshotList()
  echo "  Remaining snapshots: ", remaining.len

  # Cleanup
  echo ""
  echo "Cleaning up..."
  if rc.isDefined():
    discard rc.destroy()
  if c.isDefined():
    discard c.destroy()
  echo "Done."

main()
