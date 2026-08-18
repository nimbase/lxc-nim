import std/os
import unittest
import lxc

const
  TestContainer = "nim-lxc-test"

let isRoot = getEnv("USER") == "root"

proc cleanup() =
  var c = newContainer(TestContainer)
  if c.isDefined():
    if c.isRunning():
      discard c.stop()
    discard c.destroy()

proc ensureCreated(): Container =
  result = newContainer(TestContainer)
  if not result.isDefined():
    let created = result.create(
      t = "download",
      argv = @["--dist", "alpine", "--release", "3.24", "--arch", "amd64"]
    )
    check created
    discard result.setConfigItem("lxc.net.0.type", "empty")
    discard result.saveConfig()

suite "integration - container lifecycle":
  test "create container with download template":
    if not isRoot:
      skip()
    else:
      cleanup()
      let c = ensureCreated()
      check c.isDefined()

  test "start and stop container":
    if not isRoot:
      skip()
    else:
      cleanup()
      let c = ensureCreated()
      check c.start()
      check c.isRunning()
      let s = c.state()
      check s == "RUNNING"
      check c.stop()
      discard c.wait("STOPPED", 30)
      check not c.isRunning()

  test "container state transitions":
    if not isRoot:
      skip()
    else:
      cleanup()
      let c = ensureCreated()
      check c.state() == "STOPPED"
      check not c.isRunning()
      check c.start()
      discard c.wait("RUNNING", 30)
      check c.isRunning()
      check c.state() == "RUNNING"
      check c.stop()
      discard c.wait("STOPPED", 30)
      check c.state() == "STOPPED"

  test "destroy container":
    if not isRoot:
      skip()
    else:
      cleanup()
      let c = ensureCreated()
      check c.isDefined()
      check c.destroy()
      check not c.isDefined()

suite "integration - configuration":
  test "set and get config item":
    if not isRoot:
      skip()
    else:
      cleanup()
      let c = ensureCreated()
      check c.setConfigItem("lxc.uts.name", "test-host")
      let hostname = c.getConfigItem("lxc.uts.name")
      check hostname == "test-host"

  test "list config item keys":
    if not isRoot:
      skip()
    else:
      cleanup()
      let c = ensureCreated()
      let keys = c.getKeys("")
      check keys.len > 0

suite "integration - listing":
  test "listDefinedContainers includes test container":
    if not isRoot:
      skip()
    else:
      cleanup()
      let c = ensureCreated()
      let defined = listDefinedContainers()
      var found = false
      for container in defined:
        if container.Handle.name == TestContainer:
          found = true
          break
      check found
