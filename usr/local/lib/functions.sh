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
## <function_name>......................<description>
## echoC()..............................output colourised text
## resetC().............................reset colourised text
## beQuiet()............................make given commands quiet
## isEmpty()............................check, if a given string is empty
## isNumeric()..........................check, if a given string only contains numeric characters
## isString()...........................check, if a given string only contains string characters
## isLowercaseString()..................check, if a given string only contains lowercase characters
## isLowercaseUnderscoreString()........check, if a given string only contains lowercase and underscore characters
## isUppercaseString()..................check, if a given string only contains uppercase characters
## isAlphanumeric().....................check, if a given string only contains alphanumeric characters
## isSpecial()..........................check, if a given string only contains special printable characters
## isVerySpecial()......................check, if a given string only contains special non-printable characters
## checkCommands()......................check, if a command was not found and exit with exit code "127"
## prepareLogDirectory()................prepare a log directory
## createAndRemoveLockFile()............create a lock file to prevent multiple executions of a script
## outputErrorAndExit().................helper function, to output a given error message and exit with given error code
## countDown()..........................countdown timer in seconds
## createSystemLogEntry()...............add dynamic system log entries to "/var/log/syslog" and "/var/log/messages"
## setGraphicsPowerMethodAndProfile()...set graphics card power method or profile
## getGraphicsPowerMethodType().........get graphics card power method type

# define environment variables
SCRIPT_NAME="${0##*/}"
SCRIPT_DIRECTORY_PATH="${0%/*}"
SCRIPT_PID="${$}"
declare -a COMMAND_LIST
COMMAND_LIST=("/bin/chmod" "/usr/bin/flock" "/usr/bin/logger" "/bin/rm" "/bin/sleep" "/usr/bin/sudo" "/usr/bin/tee" "/bin/touch")
LOCK_FILE_DIRECTORY_PATH="/var/lock"
LOCK_FILENAME="${SCRIPT_NAME}.lock"
declare -r LOCK_FILE="${LOCK_FILE_DIRECTORY_PATH}/${LOCK_FILENAME}"
declare -A FONT_TYPE_LIST
FONT_TYPE_LIST["bold"]="001"
FONT_TYPE_LIST["dim"]="002"
FONT_TYPE_LIST["underline"]="004"
FONT_TYPE_LIST["blink"]="005"
FONT_TYPE_LIST["reverse"]="007"
FONT_TYPE_LIST["hidden"]="008"
FONT_TYPE_LIST["strikethrough"]="009"
declare -A FONT_COLOUR_LIST
FONT_COLOUR_LIST["default"]="039"
FONT_COLOUR_LIST["black"]="030"
FONT_COLOUR_LIST["red"]="031"
FONT_COLOUR_LIST["green"]="032"
FONT_COLOUR_LIST["yellow"]="033"
FONT_COLOUR_LIST["blue"]="034"
FONT_COLOUR_LIST["magenta"]="035"
FONT_COLOUR_LIST["cyan"]="036"
FONT_COLOUR_LIST["light_grey"]="037"
FONT_COLOUR_LIST["dark_grey"]="090"
FONT_COLOUR_LIST["light_red"]="091"
FONT_COLOUR_LIST["light_green"]="092"
FONT_COLOUR_LIST["light_yellow"]="093"
FONT_COLOUR_LIST["light_blue"]="094"
FONT_COLOUR_LIST["light_magenta"]="095"
FONT_COLOUR_LIST["light_cyan"]="096"
FONT_COLOUR_LIST["white"]="097"
FONT_COLOUR_LIST["background_default"]="049"
FONT_COLOUR_LIST["background_black"]="040"
FONT_COLOUR_LIST["background_red"]="041"
FONT_COLOUR_LIST["background_green"]="042"
FONT_COLOUR_LIST["background_yellow"]="043"
FONT_COLOUR_LIST["background_blue"]="044"
FONT_COLOUR_LIST["background_magenta"]="045"
FONT_COLOUR_LIST["background_cyan"]="046"
FONT_COLOUR_LIST["background_light_grey"]="047"
FONT_COLOUR_LIST["background_dark_grey"]="100"
FONT_COLOUR_LIST["background_light_red"]="101"
FONT_COLOUR_LIST["background_light_green"]="102"
FONT_COLOUR_LIST["background_light_yellow"]="103"
FONT_COLOUR_LIST["background_light_blue"]="104"
FONT_COLOUR_LIST["background_light_magenta"]="105"
FONT_COLOUR_LIST["background_light_cyan"]="106"
FONT_COLOUR_LIST["background_light_white"]="107"
declare -A RESET_TYPE_LIST
RESET_TYPE_LIST["all"]="000"
RESET_TYPE_LIST["colour"]="039"
RESET_TYPE_LIST["background"]="049"
# "\e[021m" does not work in "alacritty"
RESET_TYPE_LIST["bold"]="003"
RESET_TYPE_LIST["dim"]="022"
RESET_TYPE_LIST["underline"]="024"
RESET_TYPE_LIST["blink"]="025"
RESET_TYPE_LIST["reverse"]="027"
RESET_TYPE_LIST["hidden"]="028"
RESET_TYPE_LIST["strikethrough"]="029"

# function: output colourised text
## external dependencies:
### outputErrorAndExit
### resetC
## required permissions:
### none
## usage:
### echoC "[<font_type>]" "[<font_colour>]" "<output_message>"
## defaults:
### none
## examples:
### echoC -n "bold" "green" "this text is bold and green, but has no newline."
### echoC "" "bold" "red" "this text is bold and red."
### echoC "" "underline" "blue" "this text is underlined and blue."
### echoC "" "reverse" "" "this text is reversed."
### echoC "" "" "blue" "this text is blue."
### echoC "" "" "background_yellow" "this text's background is yellow."
## references:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting

echoC()
{
    local echo_parameter="${1}"
    local input_font_type="${2}"
    local input_font_colour="${3}"
    local output_message="${4}"

    if ! $(isAlphanumeric "${echo_parameter}") && ! $(isLowercaseString "${echo_parameter}") && ! $(isEmpty "${echo_parameter}")
    then
        outputErrorAndExit "error" "Entered string is not alphanumeric, lowercase or empty: '${echo_parameter}'." "1"
    elif ! $(isLowercaseString "${input_font_type}") && ! $(isEmpty "${input_font_type}")
    then
        outputErrorAndExit "error" "Entered string is not lowercase or empty: '${input_font_type}'." "1"
    elif ! $(isLowercaseUnderscoreString "${input_font_colour}") && ! $(isEmpty "${input_font_colour}")
    then
        outputErrorAndExit "error" "Entered string is not lowercase or empty: '${input_font_colour}'." "1"
    elif $(isEmpty "${output_message}")
    then
        outputErrorAndExit "error" "Entered string is empty: '${output_message}'." "1"
    fi

    local output_font_type
    local output_font_colour
    local output_font_start_sequence="\e["
    local output_font_delimiter=";"
    local output_font_end_sequence="m"
    local output_font_reset="${output_font_start_sequence}0${output_font_end_sequence}"
    local font_type
    local font_colour

    if [[ "${input_font_type}" == "" ]]
    then
        output_font_delimiter=""
    else
        for font_type in "${!FONT_TYPE_LIST[@]}"
        do
            if [[ "${input_font_type}" == "${font_type}" ]]
            then
                output_font_type="${FONT_TYPE_LIST[${font_type}]}"
                break
            fi
        done
    fi

    if [[ "${input_font_colour}" == "" ]]
    then
        output_font_delimiter=""
    else
        for font_colour in "${!FONT_COLOUR_LIST[@]}"
        do
            if [[ "${input_font_colour}" == "${font_colour}" ]]
            then
                output_font_colour="${FONT_COLOUR_LIST[${font_colour}]}"
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
## defaults:
### none
## examples:
### echoC "" "bold" "red" "this text is bold and red.$(resetC 'all') this text is terminal default."
### echoC "" "underline" "blue" "this text is underlined and blue.$(resetC 'underline') this text is not underlined, but blue."
### echoC "" "reverse" "" "this text is reversed.$(resetC 'reverse') this text is terminal default."
### echoC "" "" "blue" "this text is blue.$(resetC 'colour') this text is terminal default."
### echoC "" "" "background_yellow" "this text's background is yellow.$(resetC 'background') this text is terminal default."
### echoC "" "" "background_yellow" "this text's background is yellow.$(resetC 'background') this text is terminal default. $(echoC '' 'background_yellow' 'this text'"'"'s background is yellow again')."
## references:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting

resetC()
{
    local input_font_type="${1}"
    local output_font_reset="000"
    local output_font_start_sequence="\e["
    local output_font_end_sequence="m"
    local reset_type

    for reset_type in "${!RESET_TYPE_LIST[@]}"
    do
        if [[ "${input_font_type}" == "${reset_type}" ]]
        then
            output_font_reset="${RESET_TYPE_LIST[${reset_type}]}"
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
## defaults:
### if "file_descriptor" is not set, "stdout_and_stderr" is assumed.
## examples:
### beQuiet "stdout" "ls -l"
### beQuiet "stderr" "unalias ls"
### beQuiet "stdout_and_stderr" "unalias ${COMMAND_LIST[*]##*/}"
### beQuiet "unalias command_which_does_not_exist"
## references:
### https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html

beQuiet()
{
    local file_descriptor="${1:-stdout_and_stderr}"
    local command="${2}"

    if ! $(isLowercaseUnderscoreString "${file_descriptor}")
    then
        outputErrorAndExit "error" "Entered string is not lowercase: '${file_descriptor}'." "1"
    fi

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

# function: check, if a given string is empty
## external dependencies:
### none
## required permissions:
### none
## usage:
### isEmpty "<character_string>"
## defaults:
### none
## examples:
### isEmpty ""
## references:
### none

isEmpty()
{
    local input_string="${1}"
    local empty_regex_string="^$"

    if [[ "${input_string}" =~ ${empty_regex_string} ]]
    then
        return 0
    else
        return 1
    fi
}


# function: check, if a given string only contains numeric characters
## external dependencies:
### none
## required permissions:
### none
## usage:
### isNumeric "<numeric_character_string>"
## defaults:
### none
## examples:
### isNumeric "24"
### isNumeric "-24"
### isNumeric "+24"
### isNumeric "24.24"
### isNumeric "-24.24"
### isNumeric "+24.24"
## references:
### none

isNumeric()
{
    local input_string="${1}"
    local numeric_regex_string="^[+-]?[0-9]+(\.[0-9]+)?$"

    if [[ "${input_string}" =~ ${numeric_regex_string} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains string characters
## external dependencies:
### none
## required permissions:
### none
## usage:
### isString "<character_string>"
## defaults:
### none
## examples:
### isString "nom"
### isString "NOM"
### isString "NoM"
## references:
### none

isString()
{
    local input_string="${1}"
    local string_regex_string="^[a-zA-Z]+$"

    if [[ "${input_string}" =~ ${string_regex_string} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains lowercase characters
## external dependencies:
### none
## required permissions:
### none
## usage:
### isLowercaseString "<character_string>"
## defaults:
### none
## examples:
### isLowercaseString "nom"
## references:
### none

isLowercaseString()
{
    local input_string="${1}"
    local lowercase_regex_string="^[a-z]+$"

    if [[ "${input_string}" =~ ${lowercase_regex_string} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains lowercase and underscore characters
## external dependencies:
### none
## required permissions:
### none
## usage:
### isLowercaseUnderscoreString "<character_string>"
## defaults:
### none
## examples:
### isLowercaseUnderscoreString "nom_nom"
## references:
### none

isLowercaseUnderscoreString()
{
    local input_string="${1}"
    local lowercase_underscore_regex_string="^[_a-z]+$"

    if [[ "${input_string}" =~ ${lowercase_underscore_regex_string} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains uppercase characters
## external dependencies:
### none
## required permissions:
### none
## usage:
### isLowercaseString "<character_string>"
## defaults:
### none
## examples:
### isLowercaseString "NOM"
## references:
### none

isUppercaseString()
{
    local input_string="${1}"
    local uppercase_regex_string="^[A-Z]+$"

    if [[ "${input_string}" =~ ${uppercase_regex_string} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains alphanumeric characters
## external dependencies:
### none
## required permissions:
### none
## usage:
### isAlphanumeric "<alphanumeric_character_string>"
## defaults:
### none
## examples:
### isAlphanumeric "24nom"
### isAlphanumeric "nom24"
### isAlphanumeric "24NoM"
### isAlphanumeric "24-nom"
### isAlphanumeric "nom-24"
### isAlphanumeric "24-NoM"
## references:
### none

isAlphanumeric()
{
    local input_string="${1}"
    local alphanumeric_regex_string="^[-a-zA-Z0-9]+$"

    if [[ "${input_string}" =~ ${alphanumeric_regex_string} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains special printable characters
## external dependencies:
### none
## required permissions:
### none
## usage:
### isSpecial "<special_character_string>"
## defaults:
### none
## examples:
### isSpecial "!\"§$%&/()=?\`\\"
### isSpecial '!"§$%&/()=?`\'
## references:
### https://www.ascii-code.com/
### https://www.regular-expressions.info/posixbrackets.html

isSpecial()
{
    local input_string="${1}"
    local printable_regex_string="^[^a-zA-Z0-9]+$"

    if [[ "${input_string}" =~ ${printable_regex_string} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains special non-printable characters
## external dependencies:
### none
## required permissions:
### none
## usage:
### isVerySpecial "<very_special_character_string>"
## defaults:
### none
## examples:
### isVerySpecial "ł¶ŧ←↓→øþ¨æſðđŋħł˝’»«¢„“”µ·…"
## references:
### https://www.ascii-code.com/
### https://www.regular-expressions.info/posixbrackets.html

isVerySpecial()
{
    local input_string="${1}"
    local non_printable_regex_string="^[^ -~]+$"

    if [[ "${input_string}" =~ ${non_printable_regex_string} ]]
    then
        return 0
    else
        return 1
    fi
}

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
## defaults:
### if "log_directory_permissions" is not set, "750" is assumed.
### if "log_file_permissions" is not set, "640" is assumed.
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
       outputErrorAndExit "error" "'${log_directory_path}': Is a file, but should be a directory." "1"
    elif [[ ! -d "${log_directory_path}" ]]
    then
        /bin/mkdir --parents --mode="${log_directory_permissions}" "${log_directory_path}"
    elif [[ ! -w "${log_directory_path}" ]]
    then
        outputErrorAndExit "error" "Directory is not writable: '${log_directory_path}'" "1"
    fi

    for application_name in "${application_name_list[@]}"
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
### countDown "<output_message>" "<countdown_seconds>"
## defaults:
### if "countdown_seconds" is not set, "30" is assumed.
## examples:
### countDown "Exiting script in" "30"
## references:
### none

countDown()
{
    local output_message="${1}"
    local countdown_seconds="${2:-30}"

    echoC -n "bold" "red" "${output_message} ... "
    while (( "${countdown_seconds}" > 0 ))
    do
        echoC -n "bold" "red" "${countdown_seconds} "
        /bin/sleep 1
        (( countdown_seconds-- ))
    done
    echo ""
}

# function: add dynamic system log entries to "/var/log/syslog" and "/var/log/messages"
## external dependencies:
### logger
## required permissions:
### none
## usage:
### createSystemLogEntry "[<log_message>]"
## defaults:
### if "log_message" is not set, "executed" is assumed.
## examples:
### createSystemLogEntry "executed"
### createSystemLogEntry "set graphics card power profile to '${graphics_power_profile_set}'"
## references:
### none

createSystemLogEntry()
{
    local log_message="${1:-executed}"

    /usr/bin/logger --tag "${SCRIPT_NAME}" --id="${SCRIPT_PID}" --stderr "${SCRIPT_DIRECTORY_PATH}/${SCRIPT_NAME}: ${log_message}"
}

# function: set graphics card power method or profile
## external dependencies:
### beQuiet
### createSystemLogEntry
### getGraphicsPowerMethodType
### outputErrorAndExit
### sudo
### tee
## required permissions:
### The following entries in "/etc/sudoers.d/98-gfx-power-method-profile":
### <username> <hostname>=NOPASSWD: /usr/bin/tee /sys/class/drm/card0/device/power_method
### <username> <hostname>=NOPASSWD: /usr/bin/tee /sys/class/drm/card0/device/power_profile
## usage:
### setGraphicsPowerMethodAndProfile "<power_method>" "<profile_type>"
## defaults:
### none
## examples:
### setGraphicsPowerMethodAndProfile "profile" "default"
### setGraphicsPowerMethodAndProfile "profile" "auto"
### setGraphicsPowerMethodAndProfile "profile" "low"
### setGraphicsPowerMethodAndProfile "profile" "mid"
### setGraphicsPowerMethodAndProfile "profile" "high"
## references:
### https://wiki.gentoo.org/wiki/Radeon#Power_management
### https://www.x.org/wiki/RadeonFeature/#kmspowermanagementoptions

setGraphicsPowerMethodAndProfile()
{
    local graphics_power_method_set="${1}"
    local graphics_power_profile_set="${2}"
    local graphics_power_profile_file="/sys/class/drm/card0/device/power_profile"
    local current_graphics_power_method_type=$(getGraphicsPowerMethodType)

    if [[ ! -f "${graphics_power_profile_file}" ]]
    then
        outputErrorAndExit "error" "File not found: '${graphics_power_profile_file}'." "1"
    elif [[ "${graphics_power_method_set}" == "${current_graphics_power_method_type}" ]]
    then
        echo "${graphics_power_profile_set}" | beQuiet "stdout" "/usr/bin/sudo /usr/bin/tee ${graphics_power_profile_file}"
        createSystemLogEntry "set graphics card power profile to '${graphics_power_profile_set}'"
    else
        echo "${graphics_power_method_set}" | beQuiet "stdout" "/usr/bin/sudo /usr/bin/tee ${graphics_power_method_file}"
        echo "${graphics_power_profile_set}" | beQuiet "stdout" "/usr/bin/sudo /usr/bin/tee ${graphics_power_profile_file}"
        createSystemLogEntry "set graphics card power method to '${graphics_power_method_set}' and profile to '${graphics_power_profile_set}'"
    fi
}

# function: get graphics card power method type
## external dependencies:
### outputErrorAndExit
### setGraphicsPowerMethodAndProfile
## required permissions:
### none
## usage:
### getGraphicsPowerMethodType
## defaults:
### none
## examples:
### getGraphicsPowerMethodType
## references:
### https://wiki.gentoo.org/wiki/Radeon#Power_management
### https://www.x.org/wiki/RadeonFeature/#kmspowermanagementoptions

getGraphicsPowerMethodType()
{
    local graphics_power_method_file="/sys/class/drm/card0/device/power_method"
    local current_graphics_power_method_type

    if [[ ! -f "${graphics_power_method_file}" ]]
    then
        outputErrorAndExit "error" "File not found: '${graphics_power_profile_file}'." "1"
    else
        current_graphics_power_method_type=$(< "${graphics_power_method_file}")
    fi

    echo "${current_graphics_power_method_type}"
}

# function: check, if a command was not found and exit with exit code "127"
## external dependencies:
### outputErrorAndExit
## required permissions:
### none
## usage:
### COMMAND_LIST+=("<command1>" "<command2>" "<commandn>")
### checkCommands
## defaults:
### "COMMAND_LIST" always contains the commands of this script.
## examples:
### COMMAND_LIST=("tail" "/usr/bin/tmux")
### checkCommands
## references:
### none

checkCommands()
{
    local current_command

    beQuiet "" "unalias ${COMMAND_LIST[*]##*/}"

    for current_command in "${COMMAND_LIST[@]}"
    do
        if [[ ! $(command -v "${current_command}") ]]
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
## defaults:
### if "lock_type" is not set, "exclusive" is assumed.
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
    local script_pid_string_length="${#SCRIPT_PID}"

    if [[ ! -w "${LOCK_FILE_DIRECTORY_PATH}" ]]
    then
        outputErrorAndExit "error" "Directory is not writeable: '${LOCK_FILE_DIRECTORY_PATH}'. Permission denied." "1"
    else
        /bin/touch "${LOCK_FILE}"
        /bin/chmod 644 "${LOCK_FILE}"
        # assign a free "read-only" file descriptor to "${LOCK_FILE}" and save the file descriptor value in "${lock_file_file_descriptor}". "write" would be ">" and "read-write" would be "<>".
        exec {lock_file_file_descriptor}< "${LOCK_FILE}"

        # "flock" must not be executed in a test block here!
        if $(/usr/bin/flock --"${lock_file_type}" --nonblock "${lock_file_file_descriptor}")
        then
            # unlock the file descriptor and remove the file on signal "EXIT"
            trap "/usr/bin/flock --unlock ${lock_file_file_descriptor} && /bin/rm --force ${LOCK_FILE}" EXIT
            printf "%*s%s\n" "$(( ${lock_file_max_string_length} - ${script_pid_string_length} ))" "" "${SCRIPT_PID}" > "${LOCK_FILE}"
        else
            outputErrorAndExit "warning" "Lock file is present: '${LOCK_FILE}', file descriptor '${lock_file_file_descriptor}'." "1"
        fi
    fi
}

# function: helper function, to output a given error message and exit with given error code
## external dependencies:
### none
## required permissions:
### none
## usage:
### outputErrorAndExit "<error_type>" "<error_message>" "[<exit_code>]"
## defaults:
### none
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
    local exit_code_regex_string="^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$"

    case "${error_type}" in
        "warning")
            echo -e "\e[01;33m${error_message}\e[0m" >&2
            ;;

        "error")
            echo -e "\e[01;31m${error_message}\e[0m" >&2
            ;;

        *)
            echo -e "\e[01;31mError type not found: '${error_type}'.\e[0m" >&2
            exit 1
    esac

    if [[ "${exit_code}" != "" ]]
    then
        if [[ ! "${exit_code}" =~ ${exit_code_regex_string} ]]
        then
            echo -e "\e[01;31mExit code is invalid: '${exit_code}'. Must be an integer between 0 and 255.\e[0m" >&2
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
