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

# this file should only be sourced at the beginning of a shell script!
# the access permission should be "444"

# function: make variables available to have a colourised output
## dependencies:
### none
## usage:
### enableColours
### echo -e "????????????????????????????????????
### echo -e "????????????????????????????????????
### echo -e "????????????????????????????????????

enableColours()
{
    # make this easier to use
    # something with "beginning" and "reset" font
    # echo -e "\e[01;31m<some_text>\e[0m"
    # echo -e "${bold_font_begin};${colour_red}<some_text>${bold_font_end}"
    # https://misc.flogisoft.com/bash/tip_colors_and_formatting
    bold_font_begin="\e[01"
    bold_font_end="\e[0m"
    colour_red="31m"
}

# function: check, if a command was not found and return exit code "1"
## dependencies:
### enableColours
## usage:
### command_list=(<some_command1> <some_command2> <some_commandn>)
### checkCommands

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
