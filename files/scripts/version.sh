#!/sbin/sh

#    This file contains parts from the scripts taken from the Open GApps Project by mfonville.
#
#    The Open GApps scripts are free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    These scripts are distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

# Functions & variables
file_getprop() { grep "^$2" "$1" | cut -d= -f2; }

rom_build_prop=/system/build.prop

rom_version_required=6.0
rom_version_installed="$(file_getprop $rom_build_prop "ro.build.version.release")"
 
# Prevent installation of incorrect gapps version
if [ -z "${rom_version_installed##*$rom_version_required*}" ]; then
  echo "ROM and GApps versions match...proceeding"
else
  echo "ROM and GApps versions don't match...aborting"
  exit 1
fi
