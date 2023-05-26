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
import std/strformat

const helpString = fmt"""
{programName} version {version} [Nim: {NimVersion}]

    {programName} command [options] [container] [arguments]

Command:
    enter                   run `arguments` in the container with the given name
    export                  export the desktop entries specified in `arguments`

Options:
    -d, --dry-run           Print out commands instead of executing them.
    -s, --sudo              Enter container as root
"""

proc help*(args: Args) =
  echo helpString
