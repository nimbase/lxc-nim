# Nim bindings for liblxc.
# Free functions: container creation, listing, version, logging (lxccontainer.h).
#
# (c) 2026 George Lemon | LGPL-2.1-only

import ./common
import ./container
import ./snapshot

{.push, importc, header: "<lxc/lxccontainer.h>", dynlib: "liblxc." & ext.}

# container lifecycle
proc lxc_container_new*(name: cstring, configpath: cstring): lxc_containerPtr
proc lxc_container_get*(c: lxc_containerPtr): cint
proc lxc_container_put*(c: lxc_containerPtr): cint

# listing
proc list_defined_containers*(lxcpath: cstring, names: ptr cstringArray, cret: ptr lxc_containerPtr): cint
proc list_active_containers*(lxcpath: cstring, names: ptr cstringArray, cret: ptr lxc_containerPtr): cint
proc list_all_containers*(lxcpath: cstring, names: ptr cstringArray, cret: ptr lxc_containerPtr): cint

# version / config
proc lxc_get_version*(): cstring
proc lxc_get_global_config_item*(key: cstring): cstring
proc lxc_get_wait_states*(states: ptr cstringArray): cint
proc lxc_config_item_is_supported*(key: cstring): bool
proc lxc_has_api_extension*(extension: cstring): bool

# logging
proc lxc_log_init*(log: ptr lxc_log): cint
proc lxc_log_close*()

{.pop.}
