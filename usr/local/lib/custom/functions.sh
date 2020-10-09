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
### outputErrorAndExit
## usage:
### echoC "<font_switch>" "[<font_type>]" "[<font_colour>]" "<output_message>"
## examples:
### echoC "set" "bold" "red" "hello world."
### echoC "set" "bold" "red" "hello$(echoC 'reset' 'all') world."
### echoC "set" "underline" "red" "hello$(echoC 'reset' 'underline') world."
### echoC "set "" "red" "hello$(echoC 'reset' 'all') world."
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

                "")
                    output_font_delimiter=""
                    ;;

                *)
                    outputErrorAndExit "Something went wrong defining the font type. Input: '${input_font_type}'. Output: '${output_font_type}'." "1"
            esac
            ;;

        "reset")
            case "${input_font_type}" in
                "all")
                    output_font_reset="0"
                    ;;

                "bold")
                    # "\e[21m" does not work
                    output_font_reset="39"
                    ;;

                "dim")
                    output_font_reset="22"
                    ;;

                "underline")
                    output_font_reset="24"
                    ;;

                "blink")
                    output_font_reset="25"
                    ;;

                *)
                    outputErrorAndExit "Something went wrong resetting the font type. Input: '${input_font_type}'. Output: '${output_font_type}'." "1"
            esac

            echo -e "${output_font_start_sequence}${output_font_reset}${output_font_end_sequence}"
            return 0
            ;;

        *)
            outputErrorAndExit "Something went wrong setting the font. Input: '${input_font_switch}'." "1"
    esac

    case "${input_font_colour}" in
        "red")
            output_font_colour="31"
            ;;

        "blue")
            output_font_colour="34"
            ;;

        "")
            output_font_delimiter=""
            ;;

        *)
            outputErrorAndExit "Something went wrong defining the font colour. Input: '${input_font_switch}'. Output: '${output_font_switch}'" "1"
    esac

    echo -e "${output_font_start_sequence}${output_font_type}${output_font_delimiter}${output_font_colour}${output_font_end_sequence}${output_message}${output_font_reset}"
}

# function: output all possible colours supported by the terminal
## dependencies:
### none
## usage:
### outputAllColours
## examples:
### outputAllColours
## references:
### https://misc.flogisoft.com/bash/tip_colors_and_formatting#terminals_compatibility

outputAllColours()
{
    # refactor me: adapt this
    for clbg in {40..47} {100..107} 49 ; do
    	#Foreground
    	for clfg in {30..37} {90..97} 39 ; do
    		#Formatting
    		for attr in 0 1 2 4 5 7 ; do
    			#Print the result
    			echo -en "\e[${attr};${clbg};${clfg}m ^[${attr};${clbg};${clfg}m \e[0m"
    		done
    		echo #Newline
    	done
    done

    for fgbg in 38 48 ; do # Foreground / Background
        for color in {0..255} ; do # Colors
            # Display the color
            printf "\e[${fgbg};5;%sm  %3s  \e[0m" $color $color
            # Display 6 colors per lines
            if [ $((($color + 1) % 6)) == 4 ] ; then
                echo # New line
            fi
        done
        echo # New line
    done
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
            outputErrorAndExit "Could not find command '${current_command}'." "1"
        fi
    done

    unset current_command
}

# function: helper function, to output given message and exit with error code
## dependencies:
### echoC
## usage:
### outputErrorAndExit "<error_message>" "<exit_code>"
## example:
### outputErrorAndExit "Something went wrong" "1"
## references:
### none
outputErrorAndExit()
{
    local error_message="${1}"
    local exit_code="${2}"

    echoC "set" "bold" "red" "${error_message}" >&2
    exit "${exit_code}"
}

return 0
