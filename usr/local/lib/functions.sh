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

# table of contents:
## <function_name>..............<description>
## echoC()......................output colourised text
## resetC().....................reset colourised text
## beQuiet()....................make given commands quiet
## isNumeric()..................check, if a given string only contains numeric characters
## isString()...................check, if a given string only contains string characters
## isAlphanumeric().............check, if a given string only contains alphanumeric characters
## isSpecial()..................check, if a given string only contains special characters
## checkCommands()..............check, if a command was not found and exit with exit code "127"
## prepareLogDirectory()........prepare a log directory
## createAndRemoveLockFile()....create a lock file to prevent multiple executions of a script
## outputErrorAndExit().........helper function, to output a given error message and exit with given error code
## countDown()..................countdown timer in seconds
## createSystemLogEntry().......add dynamic system log entries to "/var/log/syslog" and "/var/log/messages"

# define environment variables
script_name="${0##*/}"
script_directory_path="${0%/*}"
script_pid="${$}"
declare -a command_list
command_list=("/bin/chmod" "/usr/bin/flock" "/usr/bin/logger" "/bin/rm" "/bin/touch")
lock_file_directory_path="/var/lock"
lock_filename="${script_name}.lock"
lock_file="${lock_file_directory_path}/${lock_filename}"
declare -A font_type_list
font_type_list["bold"]="001"
font_type_list["dim"]="002"
font_type_list["underline"]="004"
font_type_list["blink"]="005"
font_type_list["reverse"]="007"
font_type_list["hidden"]="008"
font_type_list["strikethrough"]="009"
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

# function: output colourised text
## external dependencies:
### resetC
## required permissions:
### none
## usage:
### echoC "[<font_type>]" "[<font_colour>]" "<output_message>"
## examples:
### echoC "bold" "red" "this text is bold and red."
### echoC "underline" "blue" "this text is underlined and blue."
### echoC "reverse" "" "this text is reversed."
### echoC "" "blue" "this text is blue."
### echoC "" "background_yellow" "this text's background is yellow."
### echoC -n "bold" "green" "this text is bold and green, but has no newline."
## references:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting

echoC()
{
    local echo_parameter="${1}"
    local input_font_type="${2}"
    local input_font_colour="${3}"
    local output_message="${4}"
    local output_font_type
    local output_font_colour
    local output_font_start_sequence="\e["
    local output_font_delimiter=";"
    local output_font_end_sequence="m"
    local output_font_reset="${output_font_start_sequence}0${output_font_end_sequence}"
    local font_type
    local font_colour

    # preserve echo parameters, such as: "-n", ...
    if [[ "${echo_parameter}" =~ ^[a-z]+$ || "${echo_parameter}" == "" ]]
    then
        # how to shift parameters unprofessionally. :)
        unset echo_parameter
        local input_font_type="${1}"
        local input_font_colour="${2}"
        local output_message="${3}"
    fi

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

    echo -e ${echo_parameter} "${output_font_start_sequence}${output_font_type}${output_font_delimiter}${output_font_colour}${output_font_end_sequence}${output_message}${output_font_reset}"
}

# function: reset colourised text
## external dependencies:
### echoC
## required permissions:
### none
## usage:
### resetC "<font_type>"
## examples:
### echoC "bold" "red" "this text is bold and red.$(resetC 'all') this text is terminal default."
### echoC "underline" "blue" "this text is underlined and blue.$(resetC 'underline') this text is not underlined, but blue."
### echoC "reverse" "" "this text is reversed.$(resetC 'reverse') this text is terminal default."
### echoC "" "blue" "this text is blue.$(resetC 'colour') this text is terminal default."
### echoC "" "background_yellow" "this text's background is yellow.$(resetC 'background') this text is terminal default."
### echoC "" "background_yellow" "this text's background is yellow.$(resetC 'background') this text is terminal default. $(echoC '' 'background_yellow' 'this text'"'"'s background is yellow again')."
## references:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting

resetC()
{
    local input_font_type="${1}"
    local output_font_reset="000"
    local output_font_start_sequence="\e["
    local output_font_end_sequence="m"
    local reset_type

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

# function: make given commands quiet
## external dependencies:
### none
## required permissions:
### none
## usage:
### beQuiet "[<file_descriptor>]" "<command_with_parameters>"
## examples:
### beQuiet "stdout" "ls -l"
### beQuiet "stderr" "unalias ls"
### beQuiet "stdout_and_stderr" "unalias ${command_list[@]}"
### beQuiet "unalias command_which_does_not_exist"
## references:
### https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html

beQuiet()
{
    local file_descriptor="${1:-stdout_and_stderr}"
    local command="${2}"

    # set positional parameters, to make command execution via "${@}" possible.
    # "ls -l -a -t -r" becomes "ls" "-l" "-a" "-t" "-r".
    set -- ${command}

    case "${file_descriptor}" in
        "stdout")
            "${@}" >/dev/null
            ;;

        "stderr")
            "${@}" 2>/dev/null
            ;;

        "stdout_and_stderr")
            "${@}" >/dev/null 2>&1
            ;;

        *)
            "${@}" >/dev/null 2>&1
    esac
}

# function: check, if a given string only contains numeric characters
## external dependencies:
### outputErrorAndExit
## required permissions:
### none
## usage:
### isNumeric "<numeric_character_string>"
## examples:
### isNumeric "24"
### isNumeric "-24"
### isNumeric "+24"
### isNumeric "24.24"
### isNumeric "-24.24
### isNumeric "+24.24
## references:
### none

isNumeric()
{
    local input_string="${1}"
    local numeric_regex="^[+-]?[0-9]+(\.[0-9]+)?$"

    if [[ "${input_string}" =~ ${numeric_regex} ]]
    then
        return 0
    else
        outputErrorAndExit "error" "Entered string is not numeric: '${input_string}'. Must match regular expression: '${numeric_regex}'." "1"
    fi
}

# function: check, if a given string only contains string characters
## external dependencies:
### outputErrorAndExit
## required permissions:
### none
## usage:
### isString "<character_string>"
## examples:
### isString "nom"
### isString "NOM"
## references:
### none

isString()
{
    local input_string="${1}"
    local string_regex="^[a-zA-Z]+$"

    if [[ "${input_string}" =~ ${string_regex} ]]
    then
        return 0
    else
        outputErrorAndExit "error" "Entered string is not a string: '${input_string}'. Must match regular expression: '${string_regex}'." "1"
    fi
}

# function: check, if a given string only contains alphanumeric characters
## external dependencies:
### outputErrorAndExit
## required permissions:
### none
## usage:
### isNumeric "<alphanumeric_character_string>"
## examples:
### isNumeric "24nom"
### isNumeric "nom24"
### isNumeric "24NoM"
## references:
### none

isAlphanumeric()
{
    local input_string="${1}"
    local alphanumeric_regex="^[a-zA-Z0-9]+$"

    if [[ "${input_string}" =~ ${alphanumeric_regex} ]]
    then
        return 0
    else
        outputErrorAndExit "error" "Entered string is not alphanumeric: '${input_string}'. Must match regular expression: '${alphanumeric_regex}'." "1"
    fi
}

# function: check, if a given string only contains special characters
## external dependencies:
### outputErrorAndExit
## required permissions:
### none
## usage:
### isSpecial "<special_character_string>"
## examples:
### isSpecial "!\"§$%&/()=?\`\\"
### isSpecial '!"§$%&/()=?`\'
### isSpecial "ł¶ŧ←↓→øþ¨æſðđŋħł˝’»«¢„“”µ·…"
## references:
### https://www.ascii-code.com/
### https://www.regular-expressions.info/posixbrackets.html

#isSpecial()
#{
#    local input_string="${1}"
#    #local printable_regex="^[^a-zA-Z0-9]+$"
#    local printable_regex="^([ -~]|[^ -~])+?"
#
#    if [[ "${input_string}" =~ ${printable_regex} ]]
#    then
#        return 0
#    else
#        outputErrorAndExit "error" "Entered string is not special: '${input_string}'. Must match regular expression: '${printable_regex}' or '${extended_regex}'." "1"
#    fi
#}

# function: prepare a log directory
## external dependencies:
### chmod
### mkdir
### outputErrorAndExit
### touch
## required permissions:
### first parameter must be a (path to a) directory
### write permissions in the desired directory
## usage:
### application_name_list+=("<application_name1>" "<application_name2>" "<application_namen>")
### prepareLogDirectory "<log_directory_path>" "<log_directory_permissions>" <application_name_list> "<log_permissions>"
## examples:
### application_name_list+=("ssh-agent" "steam")
### prepareLogDirectory "/tmp/log" "750" application_name_list[@] "640"
### prepareLogDirectory "/tmp/log" "" application_name_list[@] ""
## references:
### none

prepareLogDirectory()
{
    local log_directory_path="${1}"
    local log_directory_permissions="${2:-750}"
    local application_name_list=("${!3}")
    local log_file_permissions="${4:-640}"
    local application_name
    local log_file_suffix="log"

    if [[ -f "${log_directory_path}" ]]
    then
       outputErrorAndExit "error" "'${log_directory_path}': Is a file, but should be a directory. Exiting ..." "1"
    elif [[ ! -d "${log_directory_path}" ]]
    then
        /bin/mkdir --parents --mode="${log_directory_permissions}" "${log_directory_path}"
    elif [[ ! -w "${log_directory_path}" ]]
    then
        outputErrorAndExit "error" "Directory is not writable: '${log_directory_path}'" "1"
    fi

    for application_name in ${application_name_list[@]}
    do
        local log_directory="${log_directory_path}/${application_name}"
        local log_file="${log_directory}/${application_name}.${log_file_suffix}"

        if [[ ! -d "${log_directory}" ]]
        then
            /bin/mkdir --parents --mode="${log_directory_permissions}" "${log_directory}"
            /bin/touch "${log_file}"
            /bin/chmod "${log_file_permissions}" "${log_file}"
        else
            continue
        fi
    done
}

# function: countdown timer in seconds
## external dependencies:
### echoC
## required permissions:
### none
## usage:
### countDown "<output_message>" "<countdown_in_seconds>"
## examples:
### countDown "Exiting script in" "30"
## references:
### none

countDown()
{
    local output_message="${1}"
    local current_countdown_seconds="${2:-30}"

    echoC -n "bold" "red" "${output_message} ... "
    while (( "${current_countdown_seconds}" > 0 ))
    do
        echoC -n "bold" "red" "${current_countdown_seconds} "
        /bin/sleep 1
        (( current_countdown_seconds-- ))
    done
}

# function: add dynamic system log entries to "/var/log/syslog" and "/var/log/messages"
## external dependencies:
### logger
## required permissions:
### none
## usage:
### createSystemLogEntry "<log_message>"
## examples:
### createSystemLogEntry "executed"
### createSystemLogEntry "set graphics card power profile to '${graphics_power_profile_set}'"
## references:
### none

createSystemLogEntry()
{
    local log_message="${1}"

    /usr/bin/logger --tag "${script_name}" --id="${script_pid}" --stderr "${script_directory_path}/${script_name}: ${log_message}"
}

# function: check, if a command was not found and exit with exit code "127"
## external dependencies:
### outputErrorAndExit
## required permissions:
### none
## usage:
### command_list+=("<command1>" "<command2>" "<commandn>")
### checkCommands
## examples:
### command_list=("tail" "/usr/bin/tmux")
### checkCommands
## references:
### none

checkCommands()
{
    local current_command

    beQuiet "unalias ${command_list[@]##/*}"

    for current_command in "${command_list[@]}"
    do
        if [[ ! $(beQuiet "stderr" "command -v ${current_command}") ]]
        then
            outputErrorAndExit "error" "Command not found: '${current_command}'." "127"
        fi
    done
}

# function: create a lock file to prevent multiple executions of a script
## external dependencies:
### chmod
### flock
### outputErrorAndExit
### printf
### touch
## required permissions:
### write permissions in the directory "/var/lock/"
## usage:
### createAndRemoveLockFile "[<lock_type>]"
## examples:
### createAndRemoveLockFile
### createAndRemoveLockFile "exclusive"
### createAndRemoveLockFile "shared"
## references:
### https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s09.html
### https://dmorgan.info/posts/linux-lock-files/
### https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_12_02.html

createAndRemoveLockFile()
{
    local lock_file_type="${1:-exclusive}"
    local lock_file_file_descriptor
    local lock_file_max_string_length="10"
    local script_pid_string_length="${#script_pid}"

    if [[ ! -w "${lock_file_directory_path}" ]]
    then
        outputErrorAndExit "error" "Directory is not writeable: '${lock_file_directory_path}'. Permission denied." "1"
    else
        /bin/touch "${lock_file}"
        /bin/chmod 644 "${lock_file}"
        # assign a free "read-only" file descriptor to "${lock_file}" and save the file descriptor value in "${lock_file_file_descriptor}". "write" would be ">" and "read-write" would be "<>".
        exec {lock_file_file_descriptor}< "${lock_file}"

        # "flock" must not be executed in a test block here!
        if $(/usr/bin/flock --"${lock_file_type}" --nonblock "${lock_file_file_descriptor}")
        then
            # unlock the file descriptor and remove the file on signal "EXIT"
            trap "/usr/bin/flock --unlock ${lock_file_file_descriptor} && /bin/rm --force ${lock_file}" EXIT
            printf "%*s%s\n" "$(( ${lock_file_max_string_length} - ${script_pid_string_length} ))" "" "${script_pid}" > "${lock_file}"
        else
            outputErrorAndExit "warning" "Lock file is present: '${lock_file}', file descriptor '${lock_file_file_descriptor}'. Exiting ..." "1"
        fi
    fi
}

# function: helper function, to output a given error message and exit with given error code
## external dependencies:
### echoC
## required permissions:
### none
## usage:
### outputErrorAndExit "<error_type>" "<error_message>" "[<exit_code>]"
## examples:
### outputErrorAndExit "error" "Something went wrong." "1"
### outputErrorAndExit "warning" "Something went wrong." "1"
### outputErrorAndExit "error" "Something went wrong, but do not exit."
### outputErrorAndExit "warning" "Something went wrong, but do not exit."
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
            echoC "bold" "red" "Exit code is invalid: '${exit_code}'. Must be an integer between 0 and 255." >&2
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
