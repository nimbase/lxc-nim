# basic.nim - Create, start, query, stop, and destroy a container.
#
# Requires root: sudo nim c --path:src -r examples/basic.nim

import std/os
import ../src/lxc

const
  ContainerName = "example-basic"

proc main() =
  echo "LXC version: ", lxcVersion()

  var c = newContainer(ContainerName)

  # Remove any leftover container with this name
  if c.isDefined():
    if c.isRunning():
      echo "Stopping existing container..."
      discard c.stop()
    echo "Destroying existing container..."
    discard c.destroy()

  # Create a container using the download template
  echo "Creating container '", ContainerName, "' with Alpine 3.24..."
  let ok = c.create(
    t = "download",
    argv = @["--dist", "alpine", "--release", "3.24", "--arch", "amd64"]
  )
  if not ok:
    echo "Failed to create container"
    quit(1)
  echo "Container created. Defined: ", c.isDefined()

  # Configure hostname
  echo "Setting hostname..."
  discard c.setConfigItem("lxc.uts.name", "my-alpine")
  echo "Hostname: ", c.getConfigItem("lxc.uts.name")

  # Disable networking (no lxcbr0 bridge on this host)
  echo "Disabling network..."
  discard c.setConfigItem("lxc.net.0.type", "empty")
  discard c.saveConfig()

  # Start the container
  echo "Starting container..."
  if not c.start():
    echo "Failed to start container"
    quit(1)
  echo "Container state: ", c.state()
  echo "Init PID: ", c.initPid()

  # Wait briefly then stop
  echo "Waiting 3 seconds..."
  sleep(3000)

  echo "Stopping container..."
  discard c.stop()
  discard c.wait("STOPPED", 30)
  echo "Container state: ", c.state()

  # Destroy the container
  echo "Destroying container..."
  if not c.destroy():
    echo "Failed to destroy container"
    quit(1)
  echo "Done. Container removed."

main()
