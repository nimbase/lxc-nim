# Package

version       = "0.1.0"
author        = "George Lemon"
description   = "Nim bindings for liblxc"
license       = "LGPL-2.1-only"
srcDir        = "src"

# Dependencies

requires "nim >= 2.2.10"

task test, "Run all tests":
  exec "nim c -r tests/test_bindings.nim"
  exec "nim c -r tests/test_api.nim"
  exec "nim c -r tests/test_lxc.nim"

task testcompile, "Verify all tests compile (no link)":
  exec "nim c --compileOnly tests/test_bindings.nim"
  exec "nim c --compileOnly tests/test_api.nim"
  exec "nim c --compileOnly tests/test_lxc.nim"
