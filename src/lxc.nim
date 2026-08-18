# Nim bindings for liblxc.
#
# LGPL-2.1-only

when defined(linux):
  {.passL: "-llxc".}

import ./lxc/bindings/[common, container, attach, snapshot, free_api]
import ./lxc/api

export common, container, attach, snapshot, free_api
export api
