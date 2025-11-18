#!/bin/sh
############################################################################
# Copyright 2020-2025 Ramon Fischer                                        #
#                                                                          #
# Licensed under the Apache License, Version 2.0 (the "License");          #
# you may not use this file except in compliance with the License.         #
# You may obtain a copy of the License at                                  #
#                                                                          #
#     http://www.apache.org/licenses/LICENSE-2.0                           #
#                                                                          #
# Unless required by applicable law or agreed to in writing, software      #
# distributed under the License is distributed on an "AS IS" BASIS,        #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
# See the License for the specific language governing permissions and      #
# limitations under the License.                                           #
############################################################################

home_directory="/home/$(id --user --name)"
xprofile_file="${home_directory}/.xprofile"
log_directory="${home_directory}/.log/awesome"
log_stdout_file="${log_directory}/awesome.log"
log_stderr_file="${log_directory}/awesome.err"

if [[ "${DBUS_SESSION_BUS_ADDRESS}" == "" ]]
then
    if [[ -f "${xprofile_file}" ]]
    then
        . "${xprofile_file}"
    else
        echo "(WW) Could not source file: '${xprofile_file}' or is not a file." >&2
    fi

    export XDG_CURRENT_DESKTOP="awesome"
    # the following part somehow gets expanded to "0xc00005". using "eval" here will cause the error "command not found", but "x" will be started anyways.
    exec dbus-launch --sh-syntax --exit-with-session awesome >> "${log_stdout_file}" 2>> "${log_stderr_file}"
fi
