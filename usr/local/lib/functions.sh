############################################################################
# Copyright 2020-2025 Ramon Fischer                                        #
#                                                                          #
# Licensed under the Apache License, Version 2.0 (the "License");          #
# you may not use this file except in compliance with the License.         #
# You may obtain a copy of the License at                                  #
#                                                                          #
#     http://www.apache.org/licenses/LICENSE-2.0                           #
#                                                                          #
# Unless required by applicable law or agreed to in writing, software      #
# distributed under the License is distributed on an "AS IS" BASIS,        #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
# See the License for the specific language governing permissions and      #
# limitations under the License.                                           #
############################################################################

# this file should only be sourced once at the beginning of a shell script!
# be careful with inputs, since they do not get intercepted perfectly!
# no shebang should be used here!
# all functions are written in "bash".
# function calls within if statements are executed in subshells, since the return values are not needed.
# the access permissions of this file should be "440"!

# table of contents:
## <function_name>......................<description>
## echoC()..............................output colourised text
## resetC().............................reset colourised text
## beQuiet()............................make given commands quiet
## isEmpty()............................check, if a given string is empty
## isNumeric()..........................check, if a given string only contains numeric characters
## isString()...........................check, if a given string only contains string characters
## isDirectoryPath()....................check, if a given string only contains a directory path
## isLowercaseString()..................check, if a given string only contains lowercase characters
## isLowercaseUnderscoreString()........check, if a given string only contains lowercase and underscore characters
## isUppercaseString()..................check, if a given string only contains uppercase characters
## isAlphanumeric().....................check, if a given string only contains alphanumeric characters
## isSpecial()..........................check, if a given string only contains special printable characters
## isVerySpecial()......................check, if a given string only contains special non-printable characters
## isChmodCompatible()..................check, if a given string is chmod compatible
## checkCommands()......................check, if a command was not found and exit with exit code "127"
## prepareLogDirectory()................prepare a log directory
## createAndRemoveLockFile()............create a lock file, to prevent multiple executions of a script
## outputErrorAndExit().................output a given error message and exit with given error code
## countDown()..........................countdown timer in seconds
## createSystemLogEntry()...............add dynamic system log entries to "/var/log/syslog" and "/var/log/messages"
## setGraphicsPowerMethodAndProfile()...set graphics card power method or profile
## getGraphicsPowerMethodType().........get graphics card power method type

# define environment variables
declare -r SCRIPT_NAME="${0##*/}"
declare -r SCRIPT_DIRECTORY_PATH="${0%/*}"
declare -r SCRIPT_PID="${$}"
declare -a COMMAND_ARRAY
COMMAND_ARRAY=(
                "/bin/chmod"
                "/usr/bin/flock"
                "/usr/bin/logger"
                "/bin/rm"
                "/bin/sleep"
                "/usr/bin/sudo"
                "/usr/bin/tee"
                "/bin/touch"
              )
declare -r LOCK_FILE_DIRECTORY_PATH="/var/lock"
declare -r LOCK_FILENAME="LCK..${SCRIPT_NAME}"
declare -r LOCK_FILE="${LOCK_FILE_DIRECTORY_PATH}/${LOCK_FILENAME}"
declare -r NUMERIC_REGEX_STRING="^[+-]?[0-9]+(\.[0-9]+)?$"
declare -r STRING_REGEX_STRING="^[a-zA-Z]+$"
declare -r DIRECTORY_PATH_REGEX_STRING="^.*\/.*$"
declare -r LOWERCASE_REGEX_STRING="^[a-z]+$"
declare -r LOWERCASE_UNDERSCORE_REGEX_STRING="^[_a-z]+$"
declare -r UPPERCASE_REGEX_STRING="^[A-Z]+$"
declare -r ALPHANUMERIC_REGEX_STRING="^[-a-zA-Z0-9]+$"
# special characters
declare -r PRINTABLE_REGEX_STRING="^[^a-zA-Z0-9]+$"
# very special characters
declare -r NON_PRINTABLE_REGEX_STRING="^[^ -~]+$"
declare -r CHMOD_REGEX_STRING="^[124]?[0-7]{3}$"
declare -A FONT_TYPE_ARRAY
FONT_TYPE_ARRAY["bold"]="001"
FONT_TYPE_ARRAY["dim"]="002"
FONT_TYPE_ARRAY["underline"]="004"
FONT_TYPE_ARRAY["blink"]="005"
FONT_TYPE_ARRAY["reverse"]="007"
FONT_TYPE_ARRAY["hidden"]="008"
FONT_TYPE_ARRAY["strikethrough"]="009"
declare -r FONT_TYPE_ARRAY
declare -A FONT_COLOUR_ARRAY
FONT_COLOUR_ARRAY["default"]="039"
FONT_COLOUR_ARRAY["black"]="030"
FONT_COLOUR_ARRAY["red"]="031"
FONT_COLOUR_ARRAY["green"]="032"
FONT_COLOUR_ARRAY["yellow"]="033"
FONT_COLOUR_ARRAY["blue"]="034"
FONT_COLOUR_ARRAY["magenta"]="035"
FONT_COLOUR_ARRAY["cyan"]="036"
FONT_COLOUR_ARRAY["light_grey"]="037"
FONT_COLOUR_ARRAY["dark_grey"]="090"
FONT_COLOUR_ARRAY["light_red"]="091"
FONT_COLOUR_ARRAY["light_green"]="092"
FONT_COLOUR_ARRAY["light_yellow"]="093"
FONT_COLOUR_ARRAY["light_blue"]="094"
FONT_COLOUR_ARRAY["light_magenta"]="095"
FONT_COLOUR_ARRAY["light_cyan"]="096"
FONT_COLOUR_ARRAY["white"]="097"
FONT_COLOUR_ARRAY["background_default"]="049"
FONT_COLOUR_ARRAY["background_black"]="040"
FONT_COLOUR_ARRAY["background_red"]="041"
FONT_COLOUR_ARRAY["background_green"]="042"
FONT_COLOUR_ARRAY["background_yellow"]="043"
FONT_COLOUR_ARRAY["background_blue"]="044"
FONT_COLOUR_ARRAY["background_magenta"]="045"
FONT_COLOUR_ARRAY["background_cyan"]="046"
FONT_COLOUR_ARRAY["background_light_grey"]="047"
FONT_COLOUR_ARRAY["background_dark_grey"]="100"
FONT_COLOUR_ARRAY["background_light_red"]="101"
FONT_COLOUR_ARRAY["background_light_green"]="102"
FONT_COLOUR_ARRAY["background_light_yellow"]="103"
FONT_COLOUR_ARRAY["background_light_blue"]="104"
FONT_COLOUR_ARRAY["background_light_magenta"]="105"
FONT_COLOUR_ARRAY["background_light_cyan"]="106"
FONT_COLOUR_ARRAY["background_light_white"]="107"
declare -r FONT_COLOUR_ARRAY
declare -A RESET_TYPE_ARRAY
RESET_TYPE_ARRAY["all"]="000"
RESET_TYPE_ARRAY["colour"]="039"
RESET_TYPE_ARRAY["background"]="049"
# "\e[021m" does not work in "alacritty"
RESET_TYPE_ARRAY["bold"]="003"
RESET_TYPE_ARRAY["dim"]="022"
RESET_TYPE_ARRAY["underline"]="024"
RESET_TYPE_ARRAY["blink"]="025"
RESET_TYPE_ARRAY["reverse"]="027"
RESET_TYPE_ARRAY["hidden"]="028"
RESET_TYPE_ARRAY["strikethrough"]="029"
declare -r RESET_TYPE_ARRAY

# function: output colourised text
## external dependencies:
### outputErrorAndExit
### resetC
### helper functions:
#### isAlphanumeric
#### isEmpty
#### isLowercaseString
#### isLowercaseUnderscoreString
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
## possible values:
### font types:
#### bold
#### dim
#### underline
#### blink
#### reverse
#### hidden
#### strikethrough
### font colours:
#### default
#### black
#### red
#### green
#### yellow
#### blue
#### magenta
#### cyan
#### light_grey
#### dark_grey
#### light_red
#### light_green
#### light_yellow
#### light_blue
#### light_magenta
#### light_cyan
#### white
#### background_default
#### background_black
#### background_red
#### background_green
#### background_yellow
#### background_blue
#### background_magenta
#### background_cyan
#### background_light_grey
#### background_dark_grey
#### background_light_red
#### background_light_green
#### background_light_yellow
#### background_light_blue
#### background_light_magenta
#### background_light_cyan
#### background_light_white
## references:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting

echoC()
{
    local echo_parameter="${1}"
    local input_font_type="${2}"
    local input_font_colour="${3}"
    local output_message="${4}"

    if ! isAlphanumeric "${echo_parameter}" && ! isEmpty "${echo_parameter}"
    then
        outputErrorAndExit "error" "Entered string is not alphanumeric or empty: '${echo_parameter}'. Must match any regular expression: '${ALPHANUMERIC_REGEX_STRING}', '${EMPTY_REGEX_STRING}'." "1"
    elif ! isLowercaseString "${input_font_type}" && ! isEmpty "${input_font_type}"
    then
        outputErrorAndExit "error" "Entered string is not lowercase or empty: '${input_font_type}'. Must match any regular expression: '${LOWERCASE_REGEX_STRING}', '${EMPTY_REGEX_STRING}'." "1"
    elif ! isLowercaseUnderscoreString "${input_font_colour}" && ! isEmpty "${input_font_colour}"
    then
        outputErrorAndExit "error" "Entered string is not lowercase (with underscores) or empty: '${input_font_colour}'. Must match any regular expression: '${LOWERCASE_UNDERSCORE_REGEX_STRING}', '${EMPTY_REGEX_STRING}'." "1"
    elif isEmpty "${output_message}"
    then
        outputErrorAndExit "error" "Entered string is empty: '${output_message}'. Must not be empty." "1"
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
        for font_type in "${!FONT_TYPE_ARRAY[@]}"
        do
            if [[ "${input_font_type}" == "${font_type}" ]]
            then
                output_font_type="${FONT_TYPE_ARRAY[${font_type}]}"
                break
            fi
        done
    fi

    if [[ "${input_font_colour}" == "" ]]
    then
        output_font_delimiter=""
    else
        for font_colour in "${!FONT_COLOUR_ARRAY[@]}"
        do
            if [[ "${input_font_colour}" == "${font_colour}" ]]
            then
                output_font_colour="${FONT_COLOUR_ARRAY[${font_colour}]}"
                break
            fi
        done
    fi

    echo -e ${echo_parameter} "${output_font_start_sequence}${output_font_type}${output_font_delimiter}${output_font_colour}${output_font_end_sequence}${output_message}${output_font_reset}"
}

# function: reset colourised text
## external dependencies:
### echoC
### helper functions:
#### isEmpty
#### isLowercaseString
## required permissions:
### none
## usage:
### resetC "<font_type>"
## defaults:
### if "${input_font_type}" is not set or contains nonsense, "000" (reset all) is assumed.
## examples:
### echoC "" "bold" "red" "this text is bold and red.$(resetC 'all') this text is terminal default."
### echoC "" "underline" "blue" "this text is underlined and blue.$(resetC 'underline') this text is not underlined, but blue."
### echoC "" "reverse" "" "this text is reversed.$(resetC 'reverse') this text is terminal default."
### echoC "" "" "blue" "this text is blue.$(resetC 'colour') this text is terminal default."
### echoC "" "" "background_yellow" "this text's background is yellow.$(resetC 'background') this text is terminal default."
### echoC "" "" "background_yellow" "this text's background is yellow.$(resetC 'background') this text is terminal default. $(echoC '' 'background_yellow' 'this text'"'"'s background is yellow again')."
### echoC "" "reverse" "blue" "This is reversed and blue.$(resetC 'nonsenseentry') This is terminal default."
### echoC "" "reverse" "magenta" "This is reversed and magenta.$(resetC) This is terminal default."
## possible values:
### reset types:
#### all
#### colour
#### background
#### bold
#### dim
#### underline
#### blink
#### reverse
#### hidden
#### strikethrough
## references:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting

resetC()
{
    local input_font_type="${1:-}"
    local output_font_start_sequence="\e["
    local output_font_end_sequence="m"
    local reset_type

    if isEmpty "${input_font_type}" && ! isLowercaseString "${input_font_type}"
    then
        output_font_reset="000"
    else
        for reset_type in "${!RESET_TYPE_ARRAY[@]}"
        do
            if [[ "${input_font_type}" == "${reset_type}" ]]
            then
                output_font_reset="${RESET_TYPE_ARRAY[${reset_type}]}"
                break
            fi
        done
    fi

    echo -e "${output_font_start_sequence}${output_font_reset}${output_font_end_sequence}"
}

# function: make given commands quiet
## external dependencies:
### outputErrorAndExit
### helper functions:
#### isEmpty
#### isLowercaseUnderscoreString
## required permissions:
### none
## usage:
### beQuiet "[<file_descriptor>]" "<command_with_parameters>"
## defaults:
### if "file_descriptor" is not set, "stdout_and_stderr" is assumed.
## examples:
### beQuiet "stdout" "ls -l"
### beQuiet "stderr" "unalias ls"
### beQuiet "stdout_and_stderr" "unalias ${COMMAND_ARRAY[*]##*/}"
### beQuiet "" "unalias command_which_does_not_exist"
## possible values:
### file descriptors:
#### stdout
#### stderr
#### stdout_and_stderr
## references:
### https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html

beQuiet()
{
    local file_descriptor="${1:-stdout_and_stderr}"
    local command_string="${2}"

    if ! isLowercaseUnderscoreString "${file_descriptor}"
    then
        outputErrorAndExit "error" "Entered string is not lowercase (with underscores): '${file_descriptor}'. Must match regular expression: '${LOWERCASE_UNDERSCORE_REGEX_STRING}'." "1"
    elif isEmpty "${command_string}"
    then
        outputErrorAndExit "error" "Entered string is empty: '${command_string}'. Must not be empty." "1"
    fi

    # set positional parameters, to make command execution via "${@}" possible.
    # "ls -l -a -t -r" becomes "ls" "-l" "-a" "-t" "-r".
    set -- ${command_string}

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
### helper functions:
#### none
## required permissions:
### none
## usage:
### isEmpty "<character_string>"
## defaults:
### none
## examples:
### isEmpty ""
## possible values:
### none
## references:
### none

isEmpty()
{
    local input_string="${1}"

    if [[ "${input_string}" == "" ]]
    then
        return 0
    else
        return 1
    fi
}


# function: check, if a given string only contains numeric characters
## external dependencies:
### none
### helper functions:
#### none
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
## possible values:
### none
## references:
### none

isNumeric()
{
    local input_string="${1}"

    if [[ "${input_string}" =~ ${NUMERIC_REGEX_STRING} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains string characters
## external dependencies:
### none
### helper functions:
#### none
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
## possible values:
### none
## references:
### none

isString()
{
    local input_string="${1}"

    if [[ "${input_string}" =~ ${STRING_REGEX_STRING} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains a directory path
## external dependencies:
### none
### helper functions:
#### none
## required permissions:
### none
## usage:
### isDirectoryPath "<character_string>"
## defaults:
### none
## examples:
### isDirectoryPath "/tmp/nom"
### isDirectoryPath "nom/nom"
### isDirectoryPath "/var/run/nom"
## possible values:
### none
## references:
### none

isDirectoryPath()
{
    local input_string="${1}"

    if [[ "${input_string}" =~ ${DIRECTORY_PATH_REGEX_STRING} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains lowercase characters
## external dependencies:
### none
### helper functions:
#### none
## required permissions:
### none
## usage:
### isLowercaseString "<character_string>"
## defaults:
### none
## examples:
### isLowercaseString "nom"
## possible values:
### none
## references:
### none

isLowercaseString()
{
    local input_string="${1}"

    if [[ "${input_string}" =~ ${LOWERCASE_REGEX_STRING} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains lowercase and underscore characters
## external dependencies:
### none
### helper functions:
#### none
## required permissions:
### none
## usage:
### isLowercaseUnderscoreString "<character_string>"
## defaults:
### none
## examples:
### isLowercaseUnderscoreString "nom_nom"
## possible values:
### none
## references:
### none

isLowercaseUnderscoreString()
{
    local input_string="${1}"

    if [[ "${input_string}" =~ ${LOWERCASE_UNDERSCORE_REGEX_STRING} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains uppercase characters
## external dependencies:
### none
### helper functions:
#### none
## required permissions:
### none
## usage:
### isLowercaseString "<character_string>"
## defaults:
### none
## examples:
### isLowercaseString "NOM"
## possible values:
### none
## references:
### none

isUppercaseString()
{
    local input_string="${1}"

    if [[ "${input_string}" =~ ${UPPERCASE_REGEX_STRING} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains alphanumeric characters
## external dependencies:
### none
### helper functions:
#### none
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
## possible values:
### none
## references:
### none

isAlphanumeric()
{
    local input_string="${1}"

    if [[ "${input_string}" =~ ${ALPHANUMERIC_REGEX_STRING} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains special printable characters
## external dependencies:
### none
### helper functions:
#### none
## required permissions:
### none
## usage:
### isSpecial "<special_character_string>"
## defaults:
### none
## examples:
### isSpecial "!\"§$%&/()=?\`\\"
### isSpecial '!"§$%&/()=?`\'
## possible values:
### none
## references:
### https://www.ascii-code.com/
### https://www.regular-expressions.info/posixbrackets.html

isSpecial()
{
    local input_string="${1}"

    if [[ "${input_string}" =~ ${PRINTABLE_REGEX_STRING} ]]
    then
        return 0
    else
        return 1
    fi
}

# function: check, if a given string only contains special non-printable characters
## external dependencies:
### none
### helper functions:
#### none
## required permissions:
### none
## usage:
### isVerySpecial "<very_special_character_string>"
## defaults:
### none
## examples:
### isVerySpecial "ł¶ŧ←↓→øþ¨æſðđŋħł˝’»«¢„“”µ·…"
## possible values:
### none
## references:
### https://www.ascii-code.com/
### https://www.regular-expressions.info/posixbrackets.html

isVerySpecial()
{
    local input_string="${1}"

    if [[ "${input_string}" =~ ${NON_PRINTABLE_REGEX_STRING} ]]
    then
        return 0
    else
        return 1
    fi
}


# function: check, if a given string is chmod compatible
## external dependencies:
### none
### helper functions:
#### none
## required permissions:
### none
## usage:
### isChmodCompatible "<octal_character_string>"
## defaults:
### none
## examples:
### isChmodCompatible "444"
### isChmodCompatible "1444"
### isChmodCompatible "2444"
### isChmodCompatible "4111"
### isChmodCompatible "00444"
## possible values:
### none
## references:
### none

isChmodCompatible()
{
    local input_string="${1}"

    if [[ "${input_string}" =~ ${CHMOD_REGEX_STRING} ]]
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
### helper functions:
#### isEmpty
#### isNumeric
#### isDirectoryPath
## required permissions:
### "${log_directory_path}" must be a (path to a) directory
### write permissions in the desired directory
## usage:
### application_name_array=("<application_name1>" "<application_name2>" "<application_namen>")
### prepareLogDirectory "<log_directory_path>" "[<log_directory_permissions>]" <application_name_array> "[<log_permissions>]"
## defaults:
### if "log_directory_permissions" is not set, "750" is assumed.
### if "log_file_permissions" is not set, "640" is assumed.
## examples:
### application_name_array=("ssh-agent" "steam")
### prepareLogDirectory "/tmp/log" "750" application_name_array[@] "640"
### prepareLogDirectory "/tmp/log" "" application_name_array[@] ""
### prepareLogDirectory "./log" "" application_name_array[@] ""
### prepareLogDirectory "log/" "" application_name_array[@] ""
## possible values:
### none
## references:
### none

prepareLogDirectory()
{
    local log_directory_path="${1}"
    local log_directory_permissions="${2:-750}"
    local application_name_array=("${!3}")
    local log_file_permissions="${4:-640}"

    if isEmpty "${log_directory_path}"
    then
        outputErrorAndExit "error" "Entered string is empty: '${log_directory_path}'. Must not be empty." "1"
    elif ! isDirectoryPath "${log_directory_path}"
    then
        outputErrorAndExit "error" "Entered string is not a directory path: '${log_directory_path}'. Must match regular expression: '${DIRECTORY_PATH_REGEX_STRING}'." "1"
    elif [[ -f "${log_directory_path}" ]]
    then
        outputErrorAndExit "error" "Entered string is not a directory: '${log_directory_path}'." "1"
    elif ! isChmodCompatible "${log_directory_permissions}"
    then
        outputErrorAndExit "error" "Entered string is not 'chmod' compatible: '${log_directory_permissions}'. Must match regular expression '${CHMOD_REGEX_STRING}'." "1"
    elif isEmpty "${application_name_array[@]}"
    then
        outputErrorAndExit "error" "Entered array is empty: '${application_name_array[*]}'. Must not be empty." "1"
    elif ! isChmodCompatible "${log_file_permissions}"
    then
        outputErrorAndExit "error" "Entered string is not 'chmod' compatible: '${log_file_permissions}'. Must match regular expression: '${CHMOD_REGEX_STRING}'." "1"
    elif [[ ! -d "${log_directory_path}" ]]
    then
        /bin/mkdir --parents --mode="${log_directory_permissions}" "${log_directory_path}"
    # write check must be done here, a non-existing directory is not writable. actually a chicken-and-egg problem, but just to be sure.
    elif [[ ! -w "${log_directory_path}" ]]
    then
        outputErrorAndExit "error" "Directory is not writable: '${log_directory_path}'. Permission denied." "1"
    fi

    local application_name
    local log_file_suffix="log"

    for application_name in "${application_name_array[@]}"
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
### helper functions:
#### isNumeric
## required permissions:
### none
## usage:
### countDown "[<output_message>]" "[<countdown_seconds>]"
## defaults:
### if "${output_message}" is not set, "Counting down" is assumed.
### if "${countdown_seconds}" is not set, "30" is assumed.
## examples:
### countDown "Exiting script in" "60"
### coundDown
### coundDown "" "20"
## possible values:
### none
## references:
### none

countDown()
{
    local output_message="${1:-Counting down}"
    local countdown_seconds="${2:-30}"

    if ! isNumeric "${countdown_seconds}"
    then
        outputErrorAndExit "error" "Entered string is not numeric: '${countdown_seconds}'. Must match regular expression: '${NUMERIC_REGEX_STRING}'." "1"
    fi

    local font_type="bold"
    local font_colour="red"

    echoC -n "${font_type}" "${font_colour}" "${output_message} ... "
    while (( "${countdown_seconds}" > 0 ))
    do
        echoC -n "${font_type}" "${font_colour}" "${countdown_seconds} "
        /bin/sleep 1
        (( countdown_seconds-- ))
    done
    echo ""
}

# function: add dynamic system log entries to "/var/log/syslog" and "/var/log/messages"
## external dependencies:
### logger
### helper functions:
#### none
## required permissions:
### none
## usage:
### createSystemLogEntry "[<log_message>]"
## defaults:
### if "${log_message}" is not set, "executed" is assumed.
## examples:
### createSystemLogEntry "executed"
### createSystemLogEntry "set graphics card power profile to '${graphics_power_profile_set}'"
## possible values:
### none
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
### helper functions:
#### isLowercaseString
## required permissions:
### The following entries in "/etc/sudoers.d/98-gfx-power-method-profile":
### <username> <hostname>=NOPASSWD: /usr/bin/tee /sys/class/drm/card0/device/power_method
### <username> <hostname>=NOPASSWD: /usr/bin/tee /sys/class/drm/card0/device/power_profile
## usage:
### setGraphicsPowerMethodAndProfile "[<power_method>]" "[<profile_type>]"
## defaults:
### if "${graphics_power_method_set}" is not set, "profile" is assumed.
### if "${graphics_power_profile_set}" is not set, "low" is assumed.
## examples:
### setGraphicsPowerMethodAndProfile "profile" "default"
### setGraphicsPowerMethodAndProfile "profile" "auto"
### setGraphicsPowerMethodAndProfile "profile" "low"
### setGraphicsPowerMethodAndProfile "profile" "mid"
### setGraphicsPowerMethodAndProfile "profile" "high"
### setGraphicsPowerMethodAndProfile "" "default"
### setGraphicsPowerMethodAndProfile "profile" ""
### setGraphicsPowerMethodAndProfile
## possible values:
### profile types:
#### dynpm
#### profile
#### dpm
### power profiles:
#### default
#### auto
#### low
#### mid
#### high
## references:
### https://wiki.gentoo.org/wiki/Radeon#Power_management
### https://www.x.org/wiki/RadeonFeature/#kmspowermanagementoptions

setGraphicsPowerMethodAndProfile()
{
    local graphics_power_method_set="${1:-profile}"
    local graphics_power_profile_set="${2:-low}"
    local current_graphics_power_method_type=$(getGraphicsPowerMethodType)

    if ! isLowercaseString "${graphics_power_method_set}"
    then
        outputErrorAndExit "error" "Entered string is not lowercase: '${graphics_power_method_set}'. Must match regular expression: '${LOWERCASE_REGEX_STRING}'." "1"
    elif ! isLowercaseString "${graphics_power_profile_set}"
    then
        outputErrorAndExit "error" "Entered string is not lowercase: '${graphics_power_profile_set}'. Must match regular expression: '${LOWERCASE_REGEX_STRING}'." "1"
    elif ! isLowercaseString "${current_graphics_power_method_type}"
    then
        outputErrorAndExit "error" "Entered string is not lowercase: '${current_graphics_power_method_type}'. Must match regular expression: '${LOWERCASE_REGEX_STRING}'." "1"
    fi

    local graphics_power_profile_file="/sys/class/drm/card0/device/power_profile"

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
### helper functions:
#### none
## required permissions:
### none
## usage:
### getGraphicsPowerMethodType
## defaults:
### none
## examples:
### getGraphicsPowerMethodType
## possible values:
### profile types:
#### dynpm
#### profile
#### dpm
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
### helper functions:
#### none
## required permissions:
### none
## usage:
### COMMAND_ARRAY=("<command1>" "<command2>" "<commandn>")
### checkCommands
## defaults:
### "${COMMAND_ARRAY[@]}" always contains the commands of this script.
## examples:
### COMMAND_ARRAY=("tail" "/usr/bin/tmux")
### checkCommands
## possible values:
### none
## references:
### none

checkCommands()
{
    local current_command

    beQuiet "" "unalias ${COMMAND_ARRAY[@]##*/}"

    for current_command in "${COMMAND_ARRAY[@]}"
    do
        if ! beQuiet "" "command -v ${current_command}"
        then
            outputErrorAndExit "error" "Command not found: '${current_command}'." "127"
        fi
    done
}

# function: create a lock file, to prevent multiple executions of a script
## external dependencies:
### chmod
### flock
### outputErrorAndExit
### printf
### touch
### helper functions:
#### none
## required permissions:
### write permissions in the directory "/var/lock/"
## usage:
### createAndRemoveLockFile "[<lock_type>]"
## defaults:
### if "${lock_type}" is not set, "exclusive" is assumed.
## examples:
### createAndRemoveLockFile
### createAndRemoveLockFile "exclusive"
### createAndRemoveLockFile "shared"
## possible values:
### exclusive
### shared
## references:
### https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s09.html
### https://dmorgan.info/posts/linux-lock-files/
### https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_12_02.html
### https://mywiki.wooledge.org/SignalTrap

createAndRemoveLockFile()
{
    local lock_file_type="${1:-exclusive}"

    if ! isLowercaseString "${lock_file_type}"
    then
        outputErrorAndExit "error" "Entered string is not lowercase: '${lock_file_type}'. Must match regular expression: '${LOWERCASE_REGEX_STRING}'." "1"
    fi

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
        if /usr/bin/flock --"${lock_file_type}" --nonblock "${lock_file_file_descriptor}"
        then
            # unlock the file descriptor and remove the file on signal "EXIT"
            trap "/usr/bin/flock --unlock ${lock_file_file_descriptor} && /bin/rm --force ${LOCK_FILE}" EXIT
            printf "%*s%s\n" "$(( ${lock_file_max_string_length} - ${script_pid_string_length} ))" "" "${SCRIPT_PID}" > "${LOCK_FILE}"
        else
            outputErrorAndExit "warning" "Lock file is present: '${LOCK_FILE}', file descriptor '${lock_file_file_descriptor}'." "1"
        fi
    fi
}

# function: output a given error message and exit with given error code
## external dependencies:
### none
### helper functions:
#### none
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
## possible values:
### none
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
