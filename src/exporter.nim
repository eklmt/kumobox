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

import std/[os, strutils, strformat]
import ./types

var xdgDirs =
  if "XDG_DATA_DIRS".existsEnv:
    "XDG_DATA_DIRS".getEnv.split ":"
  else:
    @["/usr/share"]

var home = getEnv "HOME"


proc exportIcon*(args: Args, file: string): void =
  if home == "":
    raise CatchableError.newException "HOME is unset"

  let
    name = file.extractFilename
    dir = home.joinPath(".local/share/icons/kumobox/", args.container)

  dir.createDir

  file.copyFile dir.joinPath(name)

proc exportIconName*(args: Args, name: string): void =
  if name.isAbsolute:
    args.exportIcon name
    return

  var hasExport = false

  for dir in xdgDirs:
    for file in dir.walkDirRec:
      if file.fileExists and file.splitFile.name.startsWith name:
        args.exportIcon file
        hasExport = true

  if not hasExport:
    raise CatchableError.newException fmt"Icon {name} not found"

proc exportDesktop*(args: Args, file: string): void =
  let container = "CONTAINER_ID".getEnv

  var sourceFile: File
  try:
    sourceFile = file.open()
  except IOError as e:
    stderr.write "File could not be opened!\n"
    raise e
  defer:
    sourceFile.close()

  let dest =
    if args.dryRun:
      stdout
    else:
      let destDir = home.joinPath(".local/share/applications/kumobox",
          args.container)
      destDir.createDir
      let destName = destDir.joinPath(file.extractFilename)
      let file = destName.open(fmAppend)
      if file.getFileSize != 0:
        raise IOError.newException fmt"{destName} already exists and is not empty."
      file

  for line in sourceFile.lines:
    let equalPos = line.find('=');
    if equalPos != -1:
      let key = line.substr(0, equalPos-1).strip.toLower

      case key
      of "tryexec": discard
      of "exec":
        dest.writeLine "Exec=kumobox enter ", container, " -- ", line.substr(equalPos+1)
      of "icon":
        try:
          dest.writeLine line
          if not args.dryRun:
            args.exportIconName line.substr(equalPos+1)
        except CatchableError as e:
          stderr.writeLine fmt"Warning: An icon failed to export: {e.msg}"
      else:
        dest.writeLine line
    else:
      dest.writeLine line

proc exportCommand*(command: string) =
  TODO

proc doExport*(args: Args) =
  for arg in args.positional:
    if arg.endsWith ".desktop":
      args.exportDesktop arg
    else:
      arg.exportCommand
