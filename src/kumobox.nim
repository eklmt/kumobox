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

import std/strformat
import ./types
import ./argumentParser
import ./help
import ./enter
import ./exporter
import ./create

proc main() =
  var args: Args
  try:
    args = parseArgs()
  except InvocationError as e:
    echo fmt"Invalid usage: {e.msg}"

  case args.subcommand
  of Help: args.help
  of Enter: args.enter
  of Export: args.doExport
  of Create: args.createContainer

when isMainModule:
  main()
