#!/bin/sh
#############################################################################
# Copyright 2020 Ramon Fischer                                              #
#                                                                           #
# Licensed under the Apache License, Version 2.0 (the "License");           #
# you may not use this file except in compliance with the License.          #
# You may obtain a copy of the License at                                   #
#                                                                           #
#     http://www.apache.org/licenses/LICENSE-2.0                            #
#                                                                           #
# Unless required by applicable law or agreed to in writing, software       #
# distributed under the License is distributed on an "AS IS" BASIS,         #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  #
# See the License for the specific language governing permissions and       #
# limitations under the License.                                            #
#############################################################################

xprofile_file="/home/$(id --user --name)/.xprofile"

# custom - 20200502 - rfischer: start an "x" session with "awesome" using "startx"
if [[ "${DBUS_SESSION_BUS_ADDRESS}" == "" ]]
then
    # custom - 20201001 - rfischer: make this file static by sourcing a dynamic configuration file
    if [[ -f "${xprofile_file}" ]]
    then
        . "${xprofile_file}"
    else
        echo "(WW) Could not source file '${xprofile_file}'." >&2
    fi

    # the following part somehow gets expanded to "0xc00005". using "eval" here will cause the error "command not found", but "x" will be started anyways.
    dbus-launch --sh-syntax --exit-with-session awesome
fi
