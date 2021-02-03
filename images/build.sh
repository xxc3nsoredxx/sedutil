#! /bin/bash

#   sedutil build script
#   Copyright (C) 2020-2021  xxc3nsoredxx
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

. conf

# Build the images
pushd scratch/buildroot &> /dev/null
    echo 'Building the base system ...' >> output/build_output.txt
    make |& tee -a output/build_output.txt
popd &> /dev/null

# Clean old images
echo 'Cleaning old images ...'
rm -rfv UEFI RESCUE

# Copy the images
echo 'Copying new images ...'
cp -rv scratch/buildroot/output/images/{UEFI,RESCUE} ./
