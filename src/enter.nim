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

import std/[osproc, os, strformat, strutils]
import ./types
import ./c
import ./start

proc enter*(args: Args): void =
  args.start

  var arguments = @[
    "exec", "-it",
    "--workdir", getCurrentDir()]

  if not args.sudo:
    arguments.add ["-u", $getuid()]

  for env in [
    "DISPLAY", "XAUTHORITY",
    "WAYLAND_DISPLAY",
    "LANG", "TERM",
    "XDG_RUNTIME_DIR",
    "DBUS_SESSION_BUS_ADDRESS",
  ]:
    if env.existsEnv:
      arguments.add ["--env", fmt"{env}={env.getEnv}"]

  arguments.add ["--env", fmt"CONTAINER_ID={args.container}"]
  arguments.add args.container

  if args.positional.len > 0:
    arguments.add args.positional
  else:
    arguments.add "/usr/bin/entrypoint"

  if args.dryRun:
    stdout.write args.manager
    for arg in arguments:
      if arg.contains '"':
        stdout.write " \"", arg.replace("\"", "\\\""), '"'
      else:
        stdout.write ' ', arg
    echo()
    return

  discard args.manager.findExe.startProcess("", arguments, nil, {
      poParentStreams}).waitForExit
