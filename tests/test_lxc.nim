import unittest
import lxc

test "lxc version":
  let ver = lxcVersion()
  check ver.len > 0
  echo "LXC version: ", ver

test "container handle creation":
  let c = newContainer("test-container")
  check c != nil
  check c.Handle != nil
