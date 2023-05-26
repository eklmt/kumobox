#[
kumobox, a program for host-integrated containers.
Copyright (C) 2023 124016157+eklmt@users.noreply.github.com

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]#

import std/[parseopt, strformat, strutils, os]
import ./types

template setDefaults(args: Args) =
  args.subcommand = Help
  args.positional = @[]
  args.manager = "podman"
  args.image = "archlinux:latest"
  args.container = "my-dizzybox"
  args.dryRun = false
  args.sudo = false

proc parseArgs*: Args =
  template fail(msg) = raise InvocationError.newException msg

  type PositionalState {.pure.} = enum
    psSubcommand
    Command
    Container
    NoMore

  var state = PositionalState.psSubcommand
  new result
  result.setDefaults

  var p = initOptParser("", {'d', 's'}, @[
    "",
    "dry-run",
    "sudo",
  ])

  for kind, key, val in p.getopt:
    template assertVal =
      if val == "": fail "--image requires specifying an image."

    case kind
    of cmdEnd: unreachable
    of cmdShortOption, cmdLongOption:
      case key:
      of "":
        case state:
        of psSubcommand: fail fmt"Missing subcommand."
        of Container: state = Command
        of Command: result.positional = p.remainingArgs
        of NoMore: fail "Unexpected argument \"--\""
      of "s", "sudo": result.sudo = true
      of "d", "dry-run": result.dryRun = true
      of "image":
        assertVal
        result.image = val
      else: fail fmt"{key} is not a recognized flag."

    of cmdArgument:
      state =
        case state:
        of psSubcommand:
          try:
            result.subcommand = parseEnum[Subcommand](key)
          except ValueError:
            fail fmt"Invalid subcommand {key}"

          case result.subcommand:
          of Enter: Container
          of Export:
            if not existsEnv "CONTAINER_ID":
              fail "No container ID!"
            result.container = getEnv "CONTAINER_ID"
            Command
          of Create: Container
          of Help: return # Help needs no arguments
        of Container:
          result.container = key
          if result.subcommand == Create:
            NoMore
          else:
            Command
        of Command:
          result.positional = @[key]
          result.positional.add p.remainingArgs
          return
        of NoMore:
          fail fmt"Unexpected argument {key}"
