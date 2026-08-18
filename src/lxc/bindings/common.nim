# Nim bindings for liblxc.
# Common types shared by all binding modules.
#
# (c) 2026 George Lemon | LGPL-2.1-only

const ext* =
  when defined(linux):
    "so"
  elif defined(windows):
    "dll"
  else:
    "dylib"

type
  # Opaque pointer types
  lxc_lock* {.importc: "struct lxc_lock", header: "<lxc/lxccontainer.h>", incompleteStruct.} = object
  lxc_conf* {.importc: "struct lxc_conf", header: "<lxc/lxccontainer.h>", incompleteStruct.} = object

  lxc_lockPtr* = ptr lxc_lock
  lxc_confPtr* = ptr lxc_conf

proc free*(p: pointer) {.importc: "free", header: "<stdlib.h>".}
