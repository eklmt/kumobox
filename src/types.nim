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

type
  Subcommand* {.pure.} = enum
    Help = "help"
    Enter = "enter"
    Export = "export"
    Create = "create"

  Args* = ref object
    subcommand*: Subcommand
    positional*: seq[string] # commandline/export
    manager*: string
    image*: string
    container*: string
    dryRun*: bool
    sudo*: bool              # Whether to enter as root

  InvocationError* = object of CatchableError
  FailedProcessError* = object of CatchableError

template TODO* = raise Exception.newException "Not implemented"
template unreachable* = assert false

const version* = "0.1.0"
const programName* = "kumobox"
