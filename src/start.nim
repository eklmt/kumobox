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

proc start*(args: Args): void =
  let exitCode = args.manager.findExe.startProcess("", ["start",
      args.container], nil, {poParentStreams}).waitForExit

  if exitCode != 0:
    raise FailedProcessError.newException "The container failed to start:"
