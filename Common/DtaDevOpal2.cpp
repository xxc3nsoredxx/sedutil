/* C:B**************************************************************************
This software is Copyright 2014-2017 Bright Plaza Inc. <drivetrust@drivetrust.com>
Copyright 2020-2021 xxc3nsoredxx

This file is part of sedutil.

sedutil is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

sedutil is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with sedutil.  If not, see <http://www.gnu.org/licenses/>.

 * C:E********************************************************************** */
#include <cassert>

#include "Common/DtaDevOpal2.h"

DtaDevOpal2::DtaDevOpal2 (const char *devref) {
    DtaDevOpal::init(devref);
    assert(isOpal2());
}

DtaDevOpal2::~DtaDevOpal2 () {}

uint16_t DtaDevOpal2::comID () {
    return disk_info.OPAL20_basecomID;
}
