# Nim bindings for liblxc.
# Attach options and commands (attach_options.h).
#
# (c) 2026 George Lemon | LGPL-2.1-only

import std/posix
import ./common

type
  lxc_attach_env_policy_t* = enum
    LXC_ATTACH_KEEP_ENV = 0,
    LXC_ATTACH_CLEAR_ENV = 1,

  lxc_attach_exec_t* = proc(payload: pointer): cint {.cdecl.}

  lxc_groups_t* {.importc: "lxc_groups_t", header: "<lxc/attach_options.h>".} = object
    size*: csize_t
    list*: ptr Gid

  lxc_attach_options_t* {.importc: "lxc_attach_options_t", header: "<lxc/attach_options.h>".} = object
    attach_flags*: cint
    namespaces*: cint
    personality*: clong
    initial_cwd*: cstring
    uid*: Uid
    gid*: Gid
    env_policy*: lxc_attach_env_policy_t
    extra_env_vars*: cstringArray
    extra_keep_env*: cstringArray
    stdin_fd*: cint
    stdout_fd*: cint
    stderr_fd*: cint
    log_fd*: cint
    lsm_label*: cstring
    groups*: lxc_groups_t

  lxc_attach_command_t* {.importc: "lxc_attach_command_t", header: "<lxc/attach_options.h>".} = object
    program*: cstring
    argv*: cstringArray

const
  LXC_ATTACH_MOVE_TO_CGROUP* = 0x00000001
  LXC_ATTACH_DROP_CAPABILITIES* = 0x00000002
  LXC_ATTACH_SET_PERSONALITY* = 0x00000004
  LXC_ATTACH_LSM_EXEC* = 0x00000008
  LXC_ATTACH_REMOUNT_PROC_SYS* = 0x00010000
  LXC_ATTACH_LSM_NOW* = 0x00020000
  LXC_ATTACH_NO_NEW_PRIVS* = 0x00040000
  LXC_ATTACH_TERMINAL* = 0x00080000
  LXC_ATTACH_LSM_LABEL* = 0x00100000
  LXC_ATTACH_SETGROUPS* = 0x00200000
  LXC_ATTACH_DEFAULT* = 0x0000FFFF
  LXC_ATTACH_LSM* = LXC_ATTACH_LSM_EXEC or LXC_ATTACH_LSM_NOW or LXC_ATTACH_LSM_LABEL
  LXC_ATTACH_DETECT_PERSONALITY* = not 0'i32

{.push, importc, header: "<lxc/attach_options.h>", dynlib: "liblxc." & ext.}
proc lxc_attach_run_command*(payload: pointer): cint
proc lxc_attach_run_shell*(payload: pointer): cint
{.pop.}
