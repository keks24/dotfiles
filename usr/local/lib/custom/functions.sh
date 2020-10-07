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
### enableColours
### echo -e "????????????????????????????????????
### echo -e "????????????????????????????????????
### echo -e "????????????????????????????????????
## reference:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting

enableColours()
{
    local font_type="${1}"
    local font_colour="${2}"

    case "${font_type}" in
        "bold")
            bold_red="\e[01;31m"
            ;;

        "italics")
            italics_some_colour=""
            ;;

        "background")
            background_some_colour=""
            ;;

        "end")
            font_end="\e[0m"
            ;;

        *)
            echo "some error"
    esac

    case "${font_colour}" in
        "red")
            nom="31m"
            ;;
    esac

    something="concatenate strings '\e[01;31m'"

    return something
}

# function: check, if a command was not found and return exit code "1"
## dependencies:
### enableColours
## usage:
### COMMAND_LIST=(<some_command1> <some_command2> <some_commandn>)
### checkCommands
## reference:
### none

declare -a command_list
COMMAND_LIST=()
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
