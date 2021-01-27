/* C:B**************************************************************************
This software is Copyright 2014-2017 Bright Plaza Inc. <drivetrust@drivetrust.com>

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
#include "config.h"

#include <cstring>
#include <iostream>

#include <unistd.h>

#include <sys/reboot.h>

#include "GetPassPhrase.h"
#include "log.h"
#include "UnlockSEDs.h"

/* Default to output that includes timestamps and goes to stderr*/
sedutiloutput outputFormat = sedutilNormal;

int main (int argc, char *argv []) {
    // DEBUG_LEVEL_INT is from config.h, set by --enable-debug[=LEVEL]
    CLog::Level() = CLog::FromInt(DEBUG_LEVEL_INT);
    LOG(D4) << "Legacy PBA start" << std::endl;
    printf("Boot Authorization \n");
    std::string p = GetPassPhrase("Password: ");
    UnlockSEDs((char *)p.c_str());
    if (strcmp(p.c_str(), "debug")) {
        printf("\n Access granted. Starting the system... \n");
        sync();
        reboot(RB_AUTOBOOT);
    }
    return 0;
}
