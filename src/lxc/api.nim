# Nim bindings for liblxc.
# Idiomatic, memory-safe wrapper around the thin bindings.
#
# (c) 2026 George Lemon | LGPL-2.1-only

import std/posix
import ./bindings/common
import ./bindings/[container, attach, snapshot, free_api]

type
  LxcError* = object of CatchableError
    errorNum*: cint

proc lastError(c: lxc_containerPtr): ref LxcError =
  let msg = if c.error_string != nil: $c.error_string else: "unknown lxc error"
  result = newException(LxcError, msg)
  result.errorNum = c.error_num

template check*(ret: bool, c: lxc_containerPtr) =
  if not ret:
    raise lastError(c)

# ------------------------------------------------------------------
# Container
# ------------------------------------------------------------------

type
  Container* = ref ContainerObj
  ContainerObj* = object
    Handle*: lxc_containerPtr

proc `=destroy`(self: var ContainerObj) =
  if self.Handle != nil:
    discard lxc_container_put(self.Handle)
    self.Handle = nil

proc newContainer*(name: string, configPath: string = ""): Container =
  ## Create a new container handle.
  let c = if configPath.len > 0:
    lxc_container_new(name.cstring, configPath.cstring)
  else:
    lxc_container_new(name.cstring, nil)
  if c == nil:
    raise newException(LxcError, "failed to create container handle")
  Container(Handle: c)

proc isDefined*(self: Container): bool =
  ## Determine if the container is defined on disk.
  self.Handle.is_defined(self.Handle)

proc state*(self: Container): string =
  ## Return the current state of the container as a string.
  let s = self.Handle.state(self.Handle)
  if s == nil: ""
  else: $s

proc isRunning*(self: Container): bool =
  ## Determine if the container is currently running.
  self.Handle.is_running(self.Handle)

proc initPid*(self: Container): Pid =
  ## Return the PID of the container's init process.
  self.Handle.init_pid(self.Handle)

proc initPidfd*(self: Container): cint =
  ## Return the pidfd of the container's init process.
  self.Handle.init_pidfd(self.Handle)

# ------------------------------------------------------------------
# Start / Stop
# ------------------------------------------------------------------

proc start*(self: Container, useinit: bool = false, argv: seq[string] = @[]): bool =
  ## Start the container.
  var cArgv: cstringArray
  if argv.len > 0:
    cArgv = allocCStringArray(argv)
  result = self.Handle.start(self.Handle, if useinit: 1 else: 0, cArgv)
  if argv.len > 0:
    deallocCStringArray(cArgv)

proc stop*(self: Container): bool =
  ## Stop the container.
  self.Handle.stop(self.Handle)

proc shutdown*(self: Container, timeout: int = 0): bool =
  ## Request the container to shut down.
  ## Timeout in seconds. -1 means wait forever, 0 means do not wait.
  self.Handle.shutdown(self.Handle, timeout.cint)

proc reboot*(self: Container): bool =
  ## Request the container to reboot by sending SIGINT.
  self.Handle.reboot(self.Handle)

proc reboot2*(self: Container, timeout: int = 0): bool =
  ## Request the container to reboot with a timeout.
  self.Handle.reboot2(self.Handle, timeout.cint)

# ------------------------------------------------------------------
# Freeze / Thaw
# ------------------------------------------------------------------

proc freeze*(self: Container): bool =
  ## Freeze the running container.
  self.Handle.freeze(self.Handle)

proc unfreeze*(self: Container): bool =
  ## Thaw a frozen container.
  self.Handle.unfreeze(self.Handle)

# ------------------------------------------------------------------
# Wait
# ------------------------------------------------------------------

proc wait*(self: Container, state: string, timeout: int = -1): bool =
  ## Wait for the container to reach a particular state.
  ## Timeout in seconds. -1 means wait forever, 0 means do not wait.
  self.Handle.wait(self.Handle, state.cstring, timeout.cint)

# ------------------------------------------------------------------
# Create / Destroy
# ------------------------------------------------------------------

proc create*(self: Container, t: string = "", bdevtype: string = "",
    flags: int = 0, argv: seq[string] = @[]): bool =
  ## Create a new container.
  ## ``t`` is the template name (e.g. "download").
  ## ``bdevtype`` is the backing store type (defaults to "dir").
  var cArgv: cstringArray
  if argv.len > 0:
    cArgv = allocCStringArray(argv)
  let cT = if t.len > 0: t.cstring else: nil
  let cBdev = if bdevtype.len > 0: bdevtype.cstring else: nil
  result = self.Handle.create(self.Handle, cT, cBdev, nil, flags.cint, cArgv)
  if argv.len > 0:
    deallocCStringArray(cArgv)

proc destroy*(self: Container): bool =
  ## Destroy the container. Must be stopped and have no dependent snapshots.
  self.Handle.destroy(self.Handle)

proc destroyWithSnapshots*(self: Container): bool =
  ## Destroy the container and all its snapshots.
  self.Handle.destroy_with_snapshots(self.Handle)

proc rename*(self: Container, newName: string): bool =
  ## Rename the container.
  self.Handle.rename(self.Handle, newName.cstring)

proc clone*(self: Container, newName: string, lxcpath: string = "",
    flags: int = 0, bdevtype: string = "", bdevdata: string = "",
    newsize: uint64 = 0, hookargs: seq[string] = @[]): Container =
  ## Copy or snapshot the container.
  ## Returns a new Container handle for the clone.
  var cHookargs: cstringArray
  if hookargs.len > 0:
    cHookargs = allocCStringArray(hookargs)
  let cNew = if newName.len > 0: newName.cstring else: nil
  let cPath = if lxcpath.len > 0: lxcpath.cstring else: nil
  let cBdev = if bdevtype.len > 0: bdevtype.cstring else: nil
  let cData = if bdevdata.len > 0: bdevdata.cstring else: nil
  let p = self.Handle.clone(self.Handle, cNew, cPath, flags.cint, cBdev, cData, newsize, cHookargs)
  if hookargs.len > 0:
    deallocCStringArray(cHookargs)
  if p == nil:
    raise newException(LxcError, "clone failed")
  Container(Handle: p)

# ------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------

proc loadConfig*(self: Container, altFile: string = ""): bool =
  ## Load the container configuration.
  ## Pass ``altFile`` to load from a specific path, or empty for the default.
  let f = if altFile.len > 0: altFile.cstring else: nil
  self.Handle.load_config(self.Handle, f)

proc saveConfig*(self: Container, altFile: string = ""): bool =
  ## Save the container configuration.
  ## Pass ``altFile`` to save to a specific path, or empty for the default.
  let f = if altFile.len > 0: altFile.cstring else: nil
  self.Handle.save_config(self.Handle, f)

proc clearConfig*(self: Container) =
  ## Clear the container's in-memory configuration.
  self.Handle.clear_config(self.Handle)

proc setConfigItem*(self: Container, key: string, value: string): bool =
  ## Set a configuration item (e.g. ``"lxc.uts.name"``).
  self.Handle.set_config_item(self.Handle, key.cstring, value.cstring)

proc getConfigItem*(self: Container, key: string): string =
  ## Retrieve the value of a configuration item.
  let len = self.Handle.get_config_item(self.Handle, key.cstring, nil, 0)
  if len <= 0: return ""
  var buf = newString(len)
  discard self.Handle.get_config_item(self.Handle, key.cstring, cast[cstring](addr buf[0]), len)
  result = $buf

proc getRunningConfigItem*(self: Container, key: string): string =
  ## Retrieve a configuration item from a running container.
  let s = self.Handle.get_running_config_item(self.Handle, key.cstring)
  if s == nil: return ""
  result = $s
  free(s)

proc getKeys*(self: Container, key: string = ""): string =
  ## Retrieve a list of configuration item keys given a prefix.
  ## Pass empty string for the root-level keys.
  let cKey = if key.len > 0: key.cstring else: nil
  let len = self.Handle.get_keys(self.Handle, cKey, nil, 0)
  if len <= 0: return ""
  var buf = newString(len)
  discard self.Handle.get_keys(self.Handle, cKey, cast[cstring](addr buf[0]), len)
  result = $buf

proc clearConfigItem*(self: Container, key: string): bool =
  ## Clear a configuration item.
  self.Handle.clear_config_item(self.Handle, key.cstring)

proc configFileName*(self: Container): string =
  ## Return the full path to the container's configuration file.
  let s = self.Handle.config_file_name(self.Handle)
  if s == nil: return ""
  result = $s
  free(s)

proc configPath*(self: Container): string =
  ## Return the container's configuration directory path.
  let s = self.Handle.get_config_path(self.Handle)
  if s == nil: ""
  else: $s

proc setConfigPath*(self: Container, path: string): bool =
  ## Set the container's configuration directory path.
  self.Handle.set_config_path(self.Handle, path.cstring)

# ------------------------------------------------------------------
# Cgroups
# ------------------------------------------------------------------

proc getCgroupItem*(self: Container, subsys: string): string =
  ## Retrieve a cgroup subsystem value.
  let len = self.Handle.get_cgroup_item(self.Handle, subsys.cstring, nil, 0)
  if len <= 0: return ""
  var buf = newString(len)
  discard self.Handle.get_cgroup_item(self.Handle, subsys.cstring, cast[cstring](addr buf[0]), len)
  result = $buf

proc setCgroupItem*(self: Container, subsys: string, value: string): bool =
  ## Set a cgroup subsystem value.
  self.Handle.set_cgroup_item(self.Handle, subsys.cstring, value.cstring)

# ------------------------------------------------------------------
# Networking
# ------------------------------------------------------------------

proc freeCStringArray(arr: cstringArray) =
  if arr != nil:
    var i = 0
    while arr[i] != nil:
      free(arr[i])
      inc i
    free(arr)

proc getInterfaces*(self: Container): seq[string] =
  ## Obtain a list of network interfaces in the container.
  let arr = self.Handle.get_interfaces(self.Handle)
  if arr == nil: return @[]
  result = @[]
  var i = 0
  while arr[i] != nil:
    result.add $arr[i]
    inc i
  freeCStringArray(arr)

proc getIps*(self: Container, `interface`: string = "", family: string = "",
    scope: int = 0): seq[string] =
  ## Determine the list of container IP addresses.
  ## Filter by ``interface`` name, address family (e.g. "inet"), and scope.
  let cIface = if `interface`.len > 0: `interface`.cstring else: nil
  let cFamily = if family.len > 0: family.cstring else: nil
  let arr = self.Handle.get_ips(self.Handle, cIface, cFamily, scope.cint)
  if arr == nil: return @[]
  result = @[]
  var i = 0
  while arr[i] != nil:
    result.add $arr[i]
    inc i
  freeCStringArray(arr)

proc attachInterface*(self: Container, dev: string, dstDev: string = ""): bool =
  ## Attach a network device to the container.
  let cDst = if dstDev.len > 0: dstDev.cstring else: nil
  self.Handle.attach_interface(self.Handle, dev.cstring, cDst)

proc detachInterface*(self: Container, dev: string, dstDev: string = ""): bool =
  ## Detach a network device from the container.
  let cDst = if dstDev.len > 0: dstDev.cstring else: nil
  self.Handle.detach_interface(self.Handle, dev.cstring, cDst)

# ------------------------------------------------------------------
# Console
# ------------------------------------------------------------------

proc consoleGetfd*(self: Container, ttynum: var cint): cint =
  ## Allocate a console tty for the container.
  ## Returns the ptx file descriptor.
  var ptxfd: cint
  self.Handle.console_getfd(self.Handle, addr ttynum, addr ptxfd)

proc console*(self: Container, ttynum: int = -1, stdinfd: int = 0,
    stdoutfd: int = 1, stderrfd: int = 2, escape: int = 1): cint =
  ## Allocate and run a console tty.
  ## Blocks until the console is exited by the user.
  self.Handle.console(self.Handle, ttynum.cint, stdinfd.cint, stdoutfd.cint, stderrfd.cint, escape.cint)

# ------------------------------------------------------------------
# Attach
# ------------------------------------------------------------------

proc attach*(self: Container, execFunction: lxc_attach_exec_t,
    execPayload: pointer, options: ptr lxc_attach_options_t,
    attachedProcess: ptr Pid): cint =
  ## Run a function inside the container.
  self.Handle.attach(self.Handle, execFunction, execPayload, options, attachedProcess)

proc attachRunWait*(self: Container, options: ptr lxc_attach_options_t,
    program: string, argv: seq[string] = @[]): cint =
  ## Run a program inside the container and wait for it to exit.
  var cArgv: cstringArray
  if argv.len > 0:
    cArgv = allocCStringArray(argv)
  result = self.Handle.attach_run_wait(self.Handle, options, program.cstring, cArgv)
  if argv.len > 0:
    deallocCStringArray(cArgv)

# ------------------------------------------------------------------
# Snapshots
# ------------------------------------------------------------------

proc snapshot*(self: Container, commentFile: string = ""): cint =
  ## Create a container snapshot.
  ## Returns the zero-based snapshot number, or -1 on error.
  let f = if commentFile.len > 0: commentFile.cstring else: nil
  self.Handle.snapshot(self.Handle, f)

proc snapshotList*(self: Container): seq[lxc_snapshot] =
  ## Obtain a list of container snapshots.
  var snaps: ptr lxc_snapshot = nil
  let n = self.Handle.snapshot_list(self.Handle, addr snaps)
  if n <= 0: return @[]
  result = @[]
  let arr = cast[ptr UncheckedArray[lxc_snapshot]](snaps)
  for i in 0 ..< n:
    result.add arr[i]
  free(snaps)

proc snapshotRestore*(self: Container, snapname: string, newName: string = ""): bool =
  ## Create a new container based on a snapshot.
  let cNew = if newName.len > 0: newName.cstring else: nil
  self.Handle.snapshot_restore(self.Handle, snapname.cstring, cNew)

proc snapshotDestroy*(self: Container, snapname: string): bool =
  ## Destroy the specified snapshot.
  self.Handle.snapshot_destroy(self.Handle, snapname.cstring)

proc snapshotDestroyAll*(self: Container): bool =
  ## Destroy all snapshots of the container.
  self.Handle.snapshot_destroy_all(self.Handle)

# ------------------------------------------------------------------
# Devices
# ------------------------------------------------------------------

proc addDeviceNode*(self: Container, srcPath: string, destPath: string = ""): bool =
  ## Add a device node to the container.
  let cDest = if destPath.len > 0: destPath.cstring else: nil
  self.Handle.add_device_node(self.Handle, srcPath.cstring, cDest)

proc removeDeviceNode*(self: Container, srcPath: string, destPath: string = ""): bool =
  ## Remove a device node from the container.
  let cDest = if destPath.len > 0: destPath.cstring else: nil
  self.Handle.remove_device_node(self.Handle, srcPath.cstring, cDest)

# ------------------------------------------------------------------
# Checkpoint / Restore (CRIU)
# ------------------------------------------------------------------

proc checkpoint*(self: Container, directory: string, stop: bool = false,
    verbose: bool = false): bool =
  ## Checkpoint the container using CRIU.
  self.Handle.checkpoint(self.Handle, directory.cstring, stop, verbose)

proc restoreCRIU*(self: Container, directory: string, verbose: bool = false): bool =
  ## Restore the container from a CRIU checkpoint.
  self.Handle.restore(self.Handle, directory.cstring, verbose)

# ------------------------------------------------------------------
# Control
# ------------------------------------------------------------------

proc mayControl*(self: Container): bool =
  ## Check if the caller may control the container.
  self.Handle.may_control(self.Handle)

proc wantDaemonize*(self: Container, state: bool): bool =
  ## Set whether the container should run disconnected from the terminal.
  self.Handle.want_daemonize(self.Handle, state)

proc wantCloseAllFds*(self: Container, state: bool): bool =
  ## Set whether the container should close all file descriptors on startup.
  self.Handle.want_close_all_fds(self.Handle, state)

# ------------------------------------------------------------------
# Timeout
# ------------------------------------------------------------------

proc setTimeout*(self: Container, timeout: int): bool =
  ## Set the response receive timeout for LXC commands.
  ## -1 means wait forever.
  self.Handle.set_timeout(self.Handle, timeout.cint)

# ------------------------------------------------------------------
# Mount
# ------------------------------------------------------------------

proc mount*(self: Container, source: string, target: string,
    filesystemtype: string = "", mountflags: culong = 0,
    data: pointer = nil): cint =
  ## Mount the host's ``source`` path onto the container's ``target`` path.
  let cFs = if filesystemtype.len > 0: filesystemtype.cstring else: nil
  self.Handle.mount(self.Handle, source.cstring, target.cstring, cFs, mountflags, data, nil)

proc umount*(self: Container, target: string, mountflags: culong = 0): cint =
  ## Unmount the container's ``target`` path.
  self.Handle.umount(self.Handle, target.cstring, mountflags, nil)

# ------------------------------------------------------------------
# Seccomp
# ------------------------------------------------------------------

proc seccompNotifyFd*(self: Container): cint =
  ## Retrieve a file descriptor for the container's seccomp filter.
  self.Handle.seccomp_notify_fd(self.Handle)

proc seccompNotifyFdActive*(self: Container): cint =
  ## Retrieve a file descriptor for the running container's seccomp filter.
  self.Handle.seccomp_notify_fd_active(self.Handle)

# ------------------------------------------------------------------
# Devpts
# ------------------------------------------------------------------

proc devptsFd*(self: Container): cint =
  ## Retrieve a mount fd for the container's devpts instance.
  self.Handle.devpts_fd(self.Handle)

# ------------------------------------------------------------------
# Free functions
# ------------------------------------------------------------------

proc lxcVersion*(): string =
  ## Return the LXC library version string.
  let v = lxc_get_version()
  if v == nil: ""
  else: $v

proc lxcGlobalConfigItem*(key: string): string =
  ## Retrieve the value for a global LXC configuration key.
  let v = lxc_get_global_config_item(key.cstring)
  if v == nil: ""
  else: $v

proc listDefinedContainers*(lxcpath: string = ""): seq[Container] =
  ## List all defined containers in the given lxcpath.
  let cPath = if lxcpath.len > 0: lxcpath.cstring else: nil
  var names: cstringArray = nil
  var containers: lxc_containerPtr = nil
  let n = list_defined_containers(cPath, addr names, addr containers)
  if n <= 0: return @[]
  result = @[]
  let arr = cast[ptr UncheckedArray[lxc_containerPtr]](containers)
  for i in 0 ..< n:
    result.add Container(Handle: arr[i])
  free(containers)

proc listActiveContainers*(lxcpath: string = ""): seq[Container] =
  ## List all active (running) containers in the given lxcpath.
  let cPath = if lxcpath.len > 0: lxcpath.cstring else: nil
  var names: cstringArray = nil
  var containers: lxc_containerPtr = nil
  let n = list_active_containers(cPath, addr names, addr containers)
  if n <= 0: return @[]
  result = @[]
  let arr = cast[ptr UncheckedArray[lxc_containerPtr]](containers)
  for i in 0 ..< n:
    result.add Container(Handle: arr[i])
  free(containers)

proc listAllContainers*(lxcpath: string = ""): seq[Container] =
  ## List all containers (defined and active) in the given lxcpath.
  let cPath = if lxcpath.len > 0: lxcpath.cstring else: nil
  var names: cstringArray = nil
  var containers: lxc_containerPtr = nil
  let n = list_all_containers(cPath, addr names, addr containers)
  if n <= 0: return @[]
  result = @[]
  let arr = cast[ptr UncheckedArray[lxc_containerPtr]](containers)
  for i in 0 ..< n:
    result.add Container(Handle: arr[i])
  free(containers)
