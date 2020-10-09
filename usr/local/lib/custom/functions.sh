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

# this file should only be sourced once at the beginning of a shell script!
# no shebang should be used here!
# the access permission should be "644"!

###########################
# TO-DO TO-DO TO-DO TO-DO #
###########################
#
# do a research about possible exit codes

# function: make variables available to have a colourised output
## dependencies:
### none
## usage:
### echoC "<some_font_type>" "<some_font_colour>" "<some_output_message>"
## examples:
### echoC "bold" "red" "hello world."
### echoC "bold" "red" "hello$(echoC "end") world."
## references:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting
echoC()
{
    local input_font_type="${1}"
    local input_font_colour="${2}"
    local output_message="${3}"
    local output_font_type
    local output_font_colour
    local output_font_end="\e[0m"

    case "${input_font_type}" in
        "end")
            echo -e "${output_font_end}"
            return 0
            ;;

        "bold")
            output_font_type="\e[01"
            ;;

        "italics")
            output_font_type=""
            ;;

        "background")
            output_font_type=""
            ;;

        *)
            outputErrorAndExit "Something went wrong defining the font type. Input: '${input_font_type}'. Output: '${output_font_type}'" "1"
    esac

    case "${input_font_colour}" in
        "red")
            output_font_colour="31m"
            ;;

        *)
            outputErrorAndExit "Something went wrong defining the font colour. Input: '${input_font_colour}'. Output: '${output_font_colour}'" "1"
    esac

    echo -e "${output_font_type};${output_font_colour}${output_message}${output_font_end}"
}

# function: check, if a command was not found and return exit code "1"
## dependencies:
### echoC
### outputErrorAndExit
## usage:
### command_list=(<some_command1> <some_command2> <some_commandn>)
### checkCommands
## examples:
### command_list=(tail tmux)
### checkCommands
## references:
### none
declare -a command_list
command_list=()
checkCommands()
{
    local current_command

    for current_command in "${command_list[@]}"
    do
        unalias "${current_command}" 2>/dev/null
        if [[ ! $(command -v "${current_command}" 2>/dev/null) ]]
        then
            outputErrorAndExit "Could not find command '${current_command}'." "1"
        fi
    done

    unset current_command
}

# function: helper function, to output given message and exit with error code
## dependencies:
### echoC
## usage:
### outputErrorAndExit "<some_string>" "<some_exit_code>"
## example:
### outputErrorAndExit "Something went wrong" "1"
## references:
### none
outputErrorAndExit()
{
    local error_message="${1}"
    local exit_code="${2}"

    echoC "bold" "red" "${error_message}" >&2
    exit "${exit_code}"
}

return 0
