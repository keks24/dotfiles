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
# the access permission should be "440"!

# function: output colourised text
## dependencies:
### outputErrorAndExit
### resetC
## special permissions:
### none
## usage:
### echoC "[<font_type>]" "[<font_colour>]" "<output_message>"
## examples:
### echoC "bold" "red" "this text is bold and red."
### echoC "underline" "blue" "this text is underlined and blue."
### echoC "reverse" "" "this text is reversed."
### echoC "" "blue" "this text is blue."
### echoC "" "background_yellow" "this text's background is yellow."
## references:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting

echoC()
{
    local input_font_type="${1}"
    local input_font_colour="${2}"
    local output_message="${3}"
    local output_font_type
    local output_font_colour
    local output_font_start_sequence="\e["
    local output_font_delimiter=";"
    local output_font_end_sequence="m"
    local output_font_reset="${output_font_start_sequence}0${output_font_end_sequence}"

    case "${input_font_type}" in
        "")
            output_font_delimiter=""
            ;;

        "bold")
            output_font_type="001"
            ;;

        "dim")
            output_font_type="002"
            ;;

        "underline")
            output_font_type="004"
            ;;

        "blink")
            output_font_type="005"
            ;;

        "reverse")
            output_font_type="007"
            ;;

        "hidden")
            output_font_type="008"
            ;;

        "strikethrough")
            output_font_type="009"
            ;;

        *)
            outputErrorAndExit "error" "Could not find font switch: '${input_font_switch}'." "1"
    esac

    case "${input_font_colour}" in
        "")
            output_font_delimiter=""
            ;;

        "default")
            output_font_colour="39"
            ;;

        "black")
            output_font_colour="30"
            ;;

        "red")
            output_font_colour="31"
            ;;

        "green")
            output_font_colour="32"
            ;;

        "yellow")
            output_font_colour="33"
            ;;

        "blue")
            output_font_colour="34"
            ;;

        "magenta")
            output_font_colour="35"
            ;;

        "cyan")
            output_font_colour="36"
            ;;

        "light_grey")
            output_font_colour="37"
            ;;

        "dark_grey")
            output_font_colour="90"
            ;;

        "light_red")
            output_font_colour="91"
            ;;

        "light_green")
            output_font_colour="92"
            ;;

        "light_yellow")
            output_font_colour="93"
            ;;

        "light_blue")
            output_font_colour="94"
            ;;

        "light_magenta")
            output_font_colour="95"
            ;;

        "light_cyan")
            output_font_colour="96"
            ;;

        "white")
            output_font_colour="97"
            ;;

        "background_default")
            output_font_colour="49"
            ;;

        "background_black")
            output_font_colour="40"
            ;;

        "background_red")
            output_font_colour="41"
            ;;

        "background_green")
            output_font_colour="42"
            ;;

        "background_yellow")
            output_font_colour="43"
            ;;

        "background_blue")
            output_font_colour="44"
            ;;

        "background_magenta")
            output_font_colour="45"
            ;;

        "background_cyan")
            output_font_colour="46"
            ;;

        "background_light_grey")
            output_font_colour="47"
            ;;

        "background_dark_grey")
            output_font_colour="100"
            ;;

        "background_light_red")
            output_font_colour="101"
            ;;

        "background_light_green")
            output_font_colour="102"
            ;;

        "background_light_yellow")
            output_font_colour="103"
            ;;

        "background_light_blue")
            output_font_colour="104"
            ;;

        "background_light_magenta")
            output_font_colour="105"
            ;;

        "background_light_cyan")
            output_font_colour="106"
            ;;

        "background_white")
            output_font_colour="107"
            ;;

        *)
            outputErrorAndExit "error" "Could not find font colour: '${input_font_colour}'." "1"
    esac

    echo -e "${output_font_start_sequence}${output_font_type}${output_font_delimiter}${output_font_colour}${output_font_end_sequence}${output_message}${output_font_reset}"
}

# function: reset colourised text
## dependencies:
### echoC
## special permissions:
### none
## usage:
### resetC "<font_type>"
## examples:
### echoC "bold" "red" "this text is bold and red.$(resetC 'all') this text is terminal default."
### echoC "underline" "blue" "this text is underlined and blue.$(resetC 'underline') this text is not underlined, but blue."
### echoC "reverse" "" "this text is reversed.$(resetC 'reverse') this text is terminal default."
### echoC "" "blue" "this text is blue.$(resetC 'colour') this text is terminal default."
### echoC "" "background_yellow" "this text's background is yellow.$(resetC 'background') this text is terminal default."
## references:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting

resetC()
{
    local input_font_type="${1}"
    local output_font_reset="000"
    local output_font_start_sequence="\e["
    local output_font_end_sequence="m"

    declare -A reset_type_list
    reset_type_list["all"]="000"
    reset_type_list["colour"]="039"
    reset_type_list["background"]="049"
    # "\e[021m" does not work in "alacritty"
    reset_type_list["bold"]="003"
    reset_type_list["dim"]="022"
    reset_type_list["underline"]="024"
    reset_type_list["blink"]="025"
    reset_type_list["reverse"]="027"
    reset_type_list["hidden"]="028"
    reset_type_list["strikethrough"]="029"
    reset_type_list["underline"]="024"

    for reset_type in "${!reset_type_list[@]}"
    do
        if [[ "${input_font_type}" == "${reset_type}" ]]
        then
            output_font_reset="${reset_type_list[${reset_type}]}"
            break
        else
            continue
        fi
    done

    echo -e "${output_font_start_sequence}${output_font_reset}${output_font_end_sequence}"
}

# function: check, if a command was not found and exit with exit code "127"
## dependencies:
### echoC
### outputErrorAndExit
## special permissions:
### none
## usage:
### command_list=(<command1> <command2> <commandn>)
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
            outputErrorAndExit "error" "Could not find command: '${current_command}'." "127"
        fi
    done
}

# function: helper function, to output a given error message and exit with error code
## dependencies:
### echoC
## special permissions:
### none
## usage:
### outputErrorAndExit "<error_type>" "<error_message>" "[<exit_code>]"
## examples:
### outputErrorAndExit "error" "Something went wrong." "1"
### outputErrorAndExit "warning" "Something went wrong, but is tolerable."
## references:
### https://tldp.org/LDP/abs/html/exitcodes.html

outputErrorAndExit()
{
    local error_type="${1}"
    local error_message="${2}"
    local exit_code="${3}"
    local exit_code_regex="^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$"

    case "${error_type}" in
        "warning")
            echoC "bold" "yellow" "${error_message}" >&2
            ;;

        "error")
            echoC "bold" "red" "${error_message}" >&2
            ;;

        *)
            echoC "bold" "red" "Could not find error type: '${error_type}'." >&2
            exit 1
    esac

    if [[ "${exit_code}" != "" ]]
    then
        if [[ ! "${exit_code}" =~ ${exit_code_regex} ]]
        then
            echoC "bold" "red" "The exit code '${exit_code}' is invalid. It must be an integer between 0 and 255." >&2
            exit 128
        else
            exit "${exit_code}"
        fi
    fi
}
