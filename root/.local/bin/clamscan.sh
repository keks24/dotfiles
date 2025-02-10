#!/bin/bash
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

command_list=(basename clamscan clear dirname echo freshclam logger unalias)
checkCommands()
{
    for current_command in "${command_list[@]}"
    do
        unalias ${current_command} 2>/dev/null
        if [[ ! $(command -v ${current_command} 2>/dev/null) ]]
        then
            /bin/echo -e "\e[01;31mCould not find command '${current_command}'.\e[0m"
            exit 1
        fi
    done
}

checkCommands

script_directory_path="${0%/*}"
script_name="${0##*/}"
infected_files_directory_path="/usr/local/etc/clamav/infected/"
log_file="/var/log/clamav/clamscan.log"

/usr/bin/clear
/usr/bin/logger --tag "clamscan" --id --stderr "${script_directory_path}/${script_name}: executed"

/bin/echo -e "\e[01;33mUpdating virus signature database...\e[0m"
/usr/bin/freshclam

/usr/bin/clamscan --recursive --infected --move="${infected_files_directory_path}" --log="${log_file}" "/"
