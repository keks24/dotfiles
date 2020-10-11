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
# all functions are written in "bash"
# the access permission should be "440"!

# function: output colourised text
## dependencies:
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

    local font_type
    declare -A font_type_list
    font_type_list["bold"]="001"
    font_type_list["dim"]="002"
    font_type_list["underline"]="004"
    font_type_list["blink"]="005"
    font_type_list["reverse"]="007"
    font_type_list["hidden"]="008"
    font_type_list["strikethrough"]="009"

    local font_colour
    declare -A font_colour_list
    font_colour_list["default"]="039"
    font_colour_list["black"]="030"
    font_colour_list["red"]="031"
    font_colour_list["green"]="032"
    font_colour_list["yellow"]="033"
    font_colour_list["blue"]="034"
    font_colour_list["magenta"]="035"
    font_colour_list["cyan"]="036"
    font_colour_list["light_grey"]="037"
    font_colour_list["dark_grey"]="090"
    font_colour_list["light_red"]="091"
    font_colour_list["light_green"]="092"
    font_colour_list["light_yellow"]="093"
    font_colour_list["light_blue"]="094"
    font_colour_list["light_magenta"]="095"
    font_colour_list["light_cyan"]="096"
    font_colour_list["white"]="097"
    font_colour_list["background_default"]="049"
    font_colour_list["background_black"]="040"
    font_colour_list["background_red"]="041"
    font_colour_list["background_green"]="042"
    font_colour_list["background_yellow"]="043"
    font_colour_list["background_blue"]="044"
    font_colour_list["background_magenta"]="045"
    font_colour_list["background_cyan"]="046"
    font_colour_list["background_light_grey"]="047"
    font_colour_list["background_dark_grey"]="100"
    font_colour_list["background_light_red"]="101"
    font_colour_list["background_light_green"]="102"
    font_colour_list["background_light_yellow"]="103"
    font_colour_list["background_light_blue"]="104"
    font_colour_list["background_light_magenta"]="105"
    font_colour_list["background_light_cyan"]="106"
    font_colour_list["background_light_white"]="107"

    if [[ "${input_font_type}" == "" ]]
    then
        output_font_delimiter=""
    else
        for font_type in "${!font_type_list[@]}"
        do
            if [[ "${input_font_type}" == "${font_type}" ]]
            then
                output_font_type="${font_type_list[${font_type}]}"
                break
            fi
        done
    fi

    if [[ "${input_font_colour}" == "" ]]
    then
        output_font_delimiter=""
    else
        for font_colour in "${!font_colour_list[@]}"
        do
            if [[ "${input_font_colour}" == "${font_colour}" ]]
            then
                output_font_colour="${font_colour_list[${font_colour}]}"
                break
            fi
        done
    fi

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

    local reset_type
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

    for reset_type in "${!reset_type_list[@]}"
    do
        if [[ "${input_font_type}" == "${reset_type}" ]]
        then
            output_font_reset="${reset_type_list[${reset_type}]}"
            break
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
### command_list+=("<command1>" "<command2>" "<commandn>")
### checkCommands
## examples:
### command_list=("tail" "/usr/bin/tmux")
### checkCommands
## references:
### none

declare -a command_list
command_list=("/bin/rm" "/bin/touch")
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

# function: create a lock file to prevent multiple executions of the script
## references:
### https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s09.html

script_name="${0##*/}"
lock_file_directory="/var/lock"
lock_filename="${script_name}.lock"
lock_file="${lock_file_directory}/${lock_filename}"
createLockFile()
{
    # note
    # note
    # note
    # note
    # note
    # create a lock file in "/var/lock/${script_name}.lock" with the following content (10 byte string, followed by newline)
    # <space><space>[...]<some_pid><some_newline>
    #

    # get pid number of the current script
    ## $ echo "${$}"
    #
    # create the appropiate lock file
    ## lock_file_max_string_length="10"
    ## script_pid="${$}"
    ## script_pid_string_length="${#script_pid}"
    #
    # write lock file
    ## printf "%*s%s\n" "$(( ${lock_file_max_string_length} - ${script_pid_string_length} ))" "" "${script_pid}" > /var/lock/${script_name}.lock

    if [[ ! -w "${lock_file_directory}" ]]
    then
        outputErrorAndExit "error" "Could not write lock file: '${lock_file}'. Permission denied." "1"
    else
        /bin/touch "${lock_file}"
    fi
}


# function: check, if a given lock file exists and exit
checkLockFile()
{
    if [[ -e "${lock_file}" ]]
    then
        outputErrorAndExit "warning" "Lock file is present: '${lock_file}'. Exiting ..." "1"
    fi
}

# function: remove a given lock file
#lock_file="/var/tmp/${script_name}.lock"
#/bin/rm --force "${lock_file}"

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

# check commands of this file
checkCommands

# use posix special-built-in for "true"
:
