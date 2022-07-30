#!/bin/bash
#############################################################################
# Copyright 2022 Ramon Fischer                                              #
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

command_list=(b2sum chmod clear date find logger mount mountpoint rsync sleep tee touch)
checkCommands()
{
    for current_command in "${command_list[@]}"
    do
        unalias ${current_command} 2>/dev/null
        if [[ ! $(command -v ${current_command} 2>/dev/null) ]]
        then
            echo -e "\e[01;31mCould not find command '${current_command}'.\e[0m"
            exit 1
        fi
    done
}

checkCommands

# define global variables
script_directory_path="${0%/*}"
script_name="${0##*/}"
declare -a source_directory_list
source_directory_list=("/home")
countdown_seconds="5"
current_iso_date=$(/bin/date +%Y%m%d)
current_time=$(/bin/date +%H%M%S)
log_directory="${script_directory_path}/logs"
log_filename="${current_iso_date}-${current_time}_${script_name}.log"
log_file="${log_directory}/${log_filename}"
backup_directory="${script_directory_path}/backup"
checksum_filename="checksums.b2"

calculateChecksums()
{
    pushd "${backup_directory}" >/dev/null
    /usr/bin/find . -type f -not -name "${checksum_filename}" -exec /usr/bin/b2sum "{}" + > "${checksum_filename}"
    popd >/dev/null
}

checkAndMountPartitions()
{
    for source_directory in ${source_directory_list[@]}
    do
        if ! /bin/mountpoint --quiet "${source_directory}"
        then
            /bin/mount "${source_directory}"
            echo -e "\e[01;33mMounted '${source_directory}'.\e[0m"
        fi
    done
}

correctPermissions()
{
    /bin/chmod 640 "${log_file}"
}

countDown()
{
    local current_countdown_seconds="${countdown_seconds}"

    echo -ne "\e[01;31mExecuting backup in ... \e[0m"
    while (( "${current_countdown_seconds}" > 0 ))
    do
        echo -ne "\e[01;31m${current_countdown_seconds} \e[0m"
        /bin/sleep 1
        (( current_countdown_seconds-- ))
    done
    echo ""
}

createSystemLogEntry()
{
    /usr/bin/logger --tag "manual backup" --id --stderr "${script_directory_path}/${script_name}: executed"
}

createLogFile()
{
    /bin/touch "${log_file}"

    correctPermissions
}

executeBackup()
{
    /usr/bin/rsync --delete --archive --hard-links --acls --xattrs --relative --info="progress2" --verbose "${source_directory_list[@]}" "${backup_directory}" |  /usr/bin/tee "${log_file}"
}

main()
{
    /usr/bin/clear

    checkAndMountPartitions

    countDown

    createSystemLogEntry

    createLogFile

    executeBackup

    calculateChecksums
}

main
