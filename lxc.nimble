# Package

version       = "0.1.0"
author        = "George Lemon"
description   = "Nim bindings for liblxc"
license       = "LGPL-2.1-only"
srcDir        = "src"

# Dependencies

requires "nim >= 2.2.10"

task test, "Run tests":
  exec "nim c -r tests/test_lxc.nim"
