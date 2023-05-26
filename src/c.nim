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

# uid_t is some unknown integer type
type uid_t* {.importc, exportc, header: "unistd.h".} = object
proc getuid*(): uid_t {.importc, header: "unistd.h".}
proc pause*(): cint {.importc, header: "unistd.h".}

func toLongLong(uid: uid_t): clonglong {.importc: "uid_t_toLongLong".}
{.emit: """
long long uid_t_toLongLong(uid_t uid) {
  return uid;
}
""".}

# Casts uid_t to a type that should hopefully be big enough
func `$`*(uid: uid_t): string =
  return $getuid().toLongLong
