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

# function: output colourised text
## dependencies:
### outputErrorAndExit
## usage:
### echoC "set" "[<font_type>]" "[<font_colour>]" "<output_message>"
### echoC "reset" "<font_type>"
## examples:
### echoC "set" "bold" "red" "hello world."
### echoC "set" "bold" "red" "hello$(echoC 'reset' 'all') world."
### echoC "set" "underline" "red" "hello$(echoC 'reset' 'underline') world."
### echoC "set" "underline" "red" "hello$(echoC 'reset' 'all') world."
### echoC "set" "reverse" "" "hello$(echoC 'reset' 'reverse') world."
### echoC "set" "" "blue" "hello$(echoC 'reset' 'colour') world."
### echoC "set" "" "background_blue" "hello$(echoC 'reset' 'colour') world."
## references:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting

echoC()
{
    local input_font_switch="${1}"
    local input_font_type="${2}"
    local input_font_colour="${3}"
    local output_message="${4}"
    local output_font_type
    local output_font_colour
    local output_font_start_sequence="\e["
    local output_font_delimiter=";"
    local output_font_end_sequence="m"
    local output_font_reset="${output_font_start_sequence}0${output_font_end_sequence}"

    case "${input_font_switch}" in
        "set")
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
            ;;

        "reset")
            case "${input_font_type}" in
                "all")
                    output_font_reset="000"
                    ;;

                "colour")
                    output_font_reset="039"
                    ;;

                "background")
                    output_font_reset="049"
                    ;;

                "bold")
                    # "\e[021m" does not work in "alacritty"
                    output_font_reset="039"
                    ;;

                "dim")
                    output_font_reset="022"
                    ;;

                "underline")
                    output_font_reset="024"
                    ;;

                "blink")
                    output_font_reset="025"
                    ;;

                "reverse")
                    output_font_reset="027"
                    ;;

                "hidden")
                    output_font_reset="028"
                    ;;

                "strikethrough")
                    output_font_reset="029"
                    ;;

                *)
                    outputErrorAndExit "error" "Could not find font type: '${input_font_type}'." "1"
            esac

            echo -e "${output_font_start_sequence}${output_font_reset}${output_font_end_sequence}"
            return 0
            ;;

        *)
            outputErrorAndExit "Could not find font switch: '${input_font_switch}'." "1"
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

# function: check, if a command was not found and return exit code "1"
## dependencies:
### echoC
### outputErrorAndExit
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
            outputErrorAndExit "Could not find command: '${current_command}'." "127"
        fi
    done

    unset current_command
}

# function: helper function, to output a given error message and exit with error code
## dependencies:
### echoC
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
    local exit_code_regex="^[0-9]{1,3}$"

    case "${error_type}" in
        "warning")
            echoC "set" "bold" "yellow" "${error_message}" >&2
            ;;

        "error")
            echoC "set" "bold" "red" "${error_message}" >&2
            ;;

        *)
            echoC "set" "bold" "red" "Could not find error type: '${error_type}'." >&2
            exit 1
    esac

    if [[ "${exit_code}" != "" ]]
    then
        if [[ ! "${exit_code}" =~ ${exit_code_regex} ]]
        then
            echoC "set" "bold" "red" "The exit code '${exit_code}' is invalid. It must be an integer between 0 and 255." >&2
            exit 128
        else
            exit "${exit_code}"
        fi
    fi
}
