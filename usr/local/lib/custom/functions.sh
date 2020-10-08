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

# function: make variables available to have a colourised output
## dependencies:
### none
## usage:
### enableFontColours
### echo -e "????????????????????????????????????
### echo -e "????????????????????????????????????
### echo -e "????????????????????????????????????
## reference:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting

enableFontColours()
{
    local input_font_type="${1}"
    local input_font_colour="${2}"
    local output_font_type=""
    local output_font_colour=""
    local outuput_font_type_and_colour=""

    case "${input_font_type}" in
        "end")
            return "\e[0m"
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
            echo -e "\e[01;31mSomething went wrong defining the 'font type'.\e[0m" >&2
            exit 1
    esac

    case "${input_font_colour}" in
        "red")
            output_font_colour="31m"
            ;;

        *)
            echo -e "\e[01;31mSomething went wrong defining the 'font colour'.\e[0m" >&2
            exit 1
    esac

    output_font_type_and_colour="${output_font_type};${output_font_colour}"

    return "${output_font_type_and_colour}"
}

# function: check, if a command was not found and return exit code "1"
## dependencies:
### enableColours
## usage:
### command_list=(<some_command1> <some_command2> <some_commandn>)
### checkCommands
## reference:
### none

declare -a command_list
command_list=()
checkCommands()
{
    enableColours

    local current_command

    for current_command in "${command_list[@]}"
    do
        unalias "${current_command}" 2>/dev/null
        if [[ ! $(command -v "${current_command}" 2>/dev/null) ]]
        then
            # refactor this !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            # refactor this !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            # refactor this !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            # refactor this !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            echo -e "\e[01;31mCould not find command '${current_command}'.\e[0m" >&2
            return 1
        fi
    done

    unset current_command
}

someFunctionToCheckTheReturnCodeAndThenExit()
{
    echo "nom"
}

return 0
