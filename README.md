<p align="center">
  Nim bindings for LibLXC
</p>

<p align="center">
  <code>nimble install lxc</code>
</p>

<p align="center">
  <a href="https://nimbase.github.io/lxc-nim/">API reference</a><br>
  <img src="https://github.com/nimbase/lxc-nim/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/nimbase/lxc-nim/workflows/docs/badge.svg" alt="Github Actions">
</p>

## Features

- **Full API coverage** -- Lifecycle, configuration, networking, snapshots, attach, console, CRIU checkpoint/restore, Cgroups, seccomp, mount injection, and migration
- **Two-layer architecture** -- Thin C-ABI bindings for raw access, idiomatic high-level wrapper with exceptions and GC integration
- **Memory-safe** -- Automatic reference counting via `=destroy` hooks, no manual `free` required at the high-level layer
- **Nim-idiomatic** -- `string` arguments, `seq[string]` returns, `bool` success/failure, named parameters with defaults

## Requirements

- Nim >= 2.2.10
- liblxc development headers (`liblxc-dev` on Debian/Ubuntu, `lxc-devel` on Fedora)

## Quick Start

```nim
import lxc

# Get LXC version
echo "LXC version: ", lxcVersion()

# Create a container handle
let c = newContainer("my-container")
echo "Defined: ", c.isDefined()
echo "State: ", c.state()
```

## Examples

### Create and start a container

```nim
import lxc

let c = newContainer("test-container")

# Configure the container
discard c.setConfigItem("lxc.uts.name", "test-container")
discard c.setConfigItem("lxc.rootfs.path", "dir:/var/lib/lxc/test-container/rootfs")

# Create using the "download" template
discard c.create("download", "", 0, @["--dist", "alpine", "--release", "3.20"])

# Start the container
discard c.start()
echo "Running: ", c.isRunning()

# Wait for it to stop (timeout: 30s)
discard c.wait("STOPPED", 30)

# Clean up
discard c.destroy()
```

### Manage snapshots

```nim
import lxc

let c = newContainer("my-container")

# Create a snapshot
let snapNum = c.snapshot()
echo "Created snapshot: ", snapNum

# List all snapshots
for snap in c.snapshotList():
  echo "Snapshot: ", snap.name, " at ", snap.timestamp

# Restore a snapshot
discard c.snapshotRestore("snap0", "restored-container")

# Destroy all snapshots
discard c.snapshotDestroyAll()
```

### Attach and run a command

```nim
import lxc
import lxc/bindings/attach

let c = newContainer("my-container")

# Create default attach options
var opts: lxc_attach_options_t
opts.attach_flags = LXC_ATTACH_DEFAULT
opts.namespaces = -1
opts.stdin_fd = 0
opts.stdout_fd = 1
opts.stderr_fd = 2

# Run /bin/sh inside the container
discard c.attachRunWait(addr opts, "/bin/sh")
```

### List containers

```nim
import lxc

# List all containers
for container in listAllContainers():
  echo container.state(), " - ", container.configPath()

# List only running containers
for container in listActiveContainers():
  echo "Running: ", container.configPath()
```

### Networking

```nim
import lxc

let c = newContainer("my-container")

# Get network interfaces
let ifaces = c.getInterfaces()
echo "Interfaces: ", ifaces

# Get IP addresses
let ips = c.getIps("eth0", "inet")
for ip in ips:
  echo "IP: ", ip
```

### Low-level bindings

For direct access to the C API without the high-level wrapper:

```nim
import lxc/bindings/[container, free_api]

# Create a raw container handle
let c = lxc_container_new("my-container", nil)
if c != nil:
  echo "Version: ", lxc_get_version()

  # Call methods directly via function pointers
  discard c.start(c, 0, nil)
  discard c.stop(c)

  # Manual reference management
  discard lxc_container_put(c)
```

## Contributing & Support

- Found a bug? [Create a new Issue](https://github.com/nimbase/lxc-nim/issues)
- Want to help? [Fork it!](https://github.com/nimbase/lxc-nim/fork)

## License

LGPL-v2.1-only license | Nim Community.
