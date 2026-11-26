#!/bin/bash
#############################################################################
# Copyright 2026 Ramon Fischer                                              #
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

# exit on failure as soon as possible
# | parameter     | name     | description                                                            |
# | ------------: | :------- | :--------------------------------------------------------------------- |
# | "-E"          | errtrace | inherit "ERR" trap in functions, command substitutions  and subshells. |
# | "-e"          | errexit  | exit immediately, if a command exits with a non-zero status.           |
# | "-u"          | nounset  | treat unset variables as an error when substituting.                   |
# | "-x"          | xtrace   | print commands and their arguments as they are executed.               |
# | "-o pipefail" | pipefail | return non-zero exit status of the rightmost command in a pipeline.    |
# see also: "bash -c 'help set'"
set -euo pipefail

# be able to kill the script gracefully within functions
## on "SIGTERM" signal, execute "exit 1"
trap 'exit 1' SIGTERM

# define global variables
## make script pid available; also for subshells ("export")
export SCRIPT_PID="${$}"

declare -a command_array
command_array=(
                "/sbin/swapoff"
                "/sbin/swapon"
              )
checkCommands()
{
    local function_name="${FUNCNAME[0]}"
    local current_command

    unalias "${command_array[*]##*/}" 2>/dev/null || true

    for current_command in "${command_array[@]}"
    do
        if ! command -v "${current_command}" >/dev/null
        then
            echo -e "\e[01;31m[${function_name}]: Could not find command '${current_command}'.\e[0m" >&2
            kill -s SIGTERM "${SCRIPT_PID}"
        fi
    done
}

checkCommands

# define more global variables
## current date and time
### requires bash >=4.4
### example: 2025-01-01T00-00-00+0000
date_time_format="\D{%Y-%m-%dT%H-%M-%S%z}"
## swap table file
swap_table_file="/proc/swaps"
declare -a swap_filename_array

executeSwapoffCommand()
{
    local swap_filename="${1}"
    local function_name="${FUNCNAME[0]}"

    echo -e "    \e[01;30m[${function_name}]: Executed at '${date_time_format@P}':\e[0m"
    time /sbin/swapoff --verbose "${swap_filename}"
}

executeSwaponCommand()
{
    local swap_filename="${1}"
    local function_name="${FUNCNAME[0]}"

    echo -e "    \e[01;30m[${function_name}]: Executed at '${date_time_format@P}':\e[0m"
    time /sbin/swapon --verbose "${swap_filename}"
}

getEnabledSwapCache()
{
    local function_name="${FUNCNAME[0]}"

    if [[ -f "${swap_table_file}" ]]
    then
        # global variable
        swap_filename_array=(
                                $(
                                    # only entries from the second row of
                                    # the first column are relevant
                                    /usr/bin/gawk \
                                        'NR >= 2{
                                            print $1;
                                        }' "${swap_table_file}"
                                 )
                            )

        # check, if there are any enabled swap file or partition entries
        if [[ "${swap_filename_array[@]}" != "" ]]
        then
            return 0
        else
            echo -e "\e[01;31m[${function_name}]: No enabled swap files or partitions found.\e[0m" >&2
            kill -s SIGTERM "${SCRIPT_PID}"
        fi
    else
        echo -e "\e[01;31m[${function_name}]: The file: '${swap_table_file}' could not be found or is not a file.\e[0m" >&2
        kill -s SIGTERM "${SCRIPT_PID}"
    fi
}
emptyAllSwapCache()
{
    local function_name="${FUNCNAME[0]}"
    local swap_filename

    for swap_filename in "${swap_filename_array[@]}"
    do
        # disable swap file or partition
        echo -e "\e[01;34m[${function_name}]: ${swap_filename}:\e[0m"
        executeSwapoffCommand "${swap_filename}"
        echo ""

        # enable swap file or partition
        executeSwaponCommand "${swap_filename}"
        echo ""
    done
}

main()
{
    getEnabledSwapCache

    emptyAllSwapCache
}

main
