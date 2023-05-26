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

import ./types
import std/osproc
import std/os
import std/strformat

proc createContainer*(args: Args): void =
  let self = expandSymlink "/proc/self/exe"
  let entrypointPath = self.parentDir.joinPath "entrypoint.sh"
  if not entrypointPath.fileExists:
    raise InvocationError.newException "entrypoint.sh appears to be missing; please use nimble install."

  template env(name: string): string =
    if not existsEnv name:
      raise InvocationError.newException name & " must be set!"
    getEnv name

  var runtimeDir = env "XDG_RUNTIME_DIR";
  var home = env "HOME"

  var arguments = [
    "create",
    "--privileged", "--net=host", "--user=0:0",
    "--volume=/run/host:/run/host",
    "--volume=/tmp:/tmp",
    "--volume=/dev:/dev",
    "--mount=type=devpts,destination=/dev/pts",
    "--entrypoint=/usr/bin/entrypoint", "--userns=keep-id",
    "--volume", fmt"{home}:{home}",
    "--volume", fmt"{runtimeDir}:{runtimeDir}",
    "--name",
    args.container, args.image,
  ]

  template run(cmd, arguments) =
    let exitCode = cmd.findExe.startProcess("", arguments, nil, {
      poParentStreams}).waitForExit

    if exitCode != 0:
      raise FailedProcessError.newException "The container failed to start:"

  args.manager.run arguments

  args.manager.run ["cp", entrypointPath,
      fmt"{args.container}:/usr/bin/entrypoint"]
