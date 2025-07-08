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

declare -a command_array
command_array=(logger sleep)
checkCommands()
{
    unalias ${command_array[@]##*/} 2>/dev/null

    for current_command in "${command_array[@]}"
    do
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

/usr/bin/logger --tag "dim monitor brightness" --id --stderr "${script_directory_path}/${script_name}: executed"

for brightness in {422..100..10}
do
    /bin/echo "${brightness}" > "/sys/class/backlight/intel_backlight/brightness"
    /bin/sleep 0.1
done
