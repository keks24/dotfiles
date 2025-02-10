#!/bin/bash
############################################################################
# Copyright 2022-2025 Ramon Fischer                                        #
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

clear
source "functions.sh"

echo "Script name: '${SCRIPT_NAME}'"
echo "Script directory path: '${SCRIPT_DIRECTORY_PATH}'"
echo "Script PID: '${SCRIPT_PID}'"
echo "Command list from 'functions.sh': '${COMMAND_ARRAY[*]}'"
echo "Lock file directory path: '${LOCK_FILE_DIRECTORY_PATH}'"
echo "Lock filename: '${LOCK_FILENAME}'"
echo "Lock file: '${LOCK_FILE}'"
echo ""

echoC -n "dim" "green" "This is dimmed and green and has no trailing newline."
echoC "" "bold" "red" "This is bold and red.$(resetC 'all') This is terminal default."
echoC "" "bold" "red" "This is bold and red.$(resetC 'bold') This is not bold, but red."
echoC "" "bold" "red" "This is bold and red.$(resetC 'colour') This is not red, but bold."
echoC "" "underline" "blue" "This is underlined and blue.$(resetC 'underline') This is not underlined, but blue."
echoC "" "" "green" "This is green.$(resetC 'colour') This is terminal default."
echoC "" "underline" "" "This is underlined.$(resetC 'underline') This is terminal default. $(echoC '' 'underline' '' 'This is underlined again.')"
echoC "" "blink" "" "This is blinking.$(resetC 'blink') This is terminal default."
echoC "" "reverse" "" "This is reversed.$(resetC 'reverse') This is terminal default."
echoC "" "hidden" "" "This is hidden.$(resetC 'hidden') This is terminal default."
echoC "" "strikethrough" "" "This is striked through.$(resetC 'strikethrough') This is terminal default."
echoC "" "reverse" "green" "This is reversed and green.$(resetC 'nonsense_entry8247082347c') This is terminal default."
echoC "" "reverse" "blue" "This is reversed and blue.$(resetC 'nonsenseentry') This is terminal default."
echoC "" "reverse" "magenta" "This is reversed and magenta.$(resetC) This is terminal default."
echoC "" "" "background_yellow" "This text's background is yellow.$(resetC 'background') This text is terminal default. $(echoC '' '' 'background_yellow' 'This text'"'"'s background is yellow again.')"
echo ""

# this should fail
#echo "Command list from 'functions.sh': '${COMMAND_ARRAY[@]}'"
#echo "${COMMAND_ARRAY[@]}"
#echo ""

#COMMAND_ARRAY=("this_command_does_not_exist")
#echo "New command list: '${COMMAND_ARRAY[@]}'"
#checkCommands
#echo ""

# this should work
echo "Command list from 'functions.sh':"
echo "${COMMAND_ARRAY[@]}"
echo ""

COMMAND_ARRAY=("ls" "hexdump")
echo "New command list from '${SCRIPT_NAME}':"
echo "${COMMAND_ARRAY[@]}"

checkCommands
echo ""

echo "Exclusive lock:"
createAndRemoveLockFile
#createAndRemoveLockFile exclusive
echo "Does the lock file '${LOCK_FILE}' exist and is world readable (.......r--)?:"
ls -l "${LOCK_FILE}"
echo ""
echo "Does the lock file contain the PID '${SCRIPT_PID}'?:"
echo "$(< ${LOCK_FILE})"
echo ""
echo "Does the lock file only contain a ten byte character string and a trailing Unix new line (0a)?:"
wc -c "${LOCK_FILE}"
hexdump --canonical "${LOCK_FILE}"
echo ""
echoC "" "" "yellow" "Please check this manually:"
echoC "" "" "yellow" "  - The lock file will be removed on process exit."
echoC "" "" "yellow" "  - During the timeout, executing another instance of '${SCRIPT_NAME}' will output everything above until the function call 'createAndRemoveLockFile' and results in a warning with exit code '1'."
echo ""

countDown "Continuing script in" "60"
echo ""

#echo "Shared lock:"
#createAndRemoveLockFile shared
#echoC "" "" "yellow" "Please check this manually:"
#echoC "" "" "yellow" "  - Executing another instance of '${SCRIPT_NAME}' this time, will not be blocked, since the lock file is 'shared'."
#
#countDown "Continuing script in" "60"
#echo ""
#echo ""

echo "Commands, executed via 'beQuiet()', should not output anything."
echo "Executing command: 'beQuiet \"stdout\" \"ls -l\"'"
beQuiet "stdout" "ls -l"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'beQuiet \"stderr\" \"unalias command_which_does_not_exist\"'"
beQuiet "stderr" "unalias command_which_does_not_exist"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'beQuiet \"stdout_and_stderr\" \"ls /tmp/file_which_does_not_exist\"'"
beQuiet "stdout_and_stderr" "ls /tmp/something_which_does_not_exist"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'beQuiet \"nonsense_entrysdfhjdsf\" \"ls /tmp/\"'"
beQuiet "nonsense_entrysdfhjdsf" "ls /tmp"
echo "Exit code: ${?}"
echo ""
echo ""

echo "The following string checks should exit with exit code '0'"
echo "Executing command: 'isEmpty \"\"'"
isEmpty ""
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isNumeric \"24\"'"
isNumeric "24"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isNumeric \"-24\"'"
isNumeric "-24"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isNumeric \"+24\"'"
isNumeric "+24"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isNumeric \"-24.24\"'"
isNumeric "-24.24"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isNumeric \"+24.24\"'"
isNumeric "+24.24"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isString \"nom\"'"
isString "nom"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isString \"NOM\"'"
isString "NOM"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isString \"NoM\"'"
isString "NoM"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isLowercaseString \"nom\"'"
isLowercaseString "nom"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isUppercaseString \"NOM\"'"
isUppercaseString "NOM"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isAlphanumeric \"nom24\"'"
isAlphanumeric "nom24"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isAlphanumeric \"24NoM\"'"
isAlphanumeric "24NoM"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isAlphanumeric \"24-nom\"'"
isAlphanumeric "24-nom"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isAlphanumeric \"nom-24\"'"
isAlphanumeric "nom-24"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isAlphanumeric \"24-NoM\"'"
isAlphanumeric "24-NoM"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isSpecial \"!\"§$%&/()=?\`\\\\\"'"
isSpecial "!\"§$%&/()=?\`\\"
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isSpecial '!§$%&/()=?\'"
isSpecial '!"§$%&/()=?`\'
echo "Exit code: ${?}"
echo ""

echo "Executing command: 'isVerySpecial \"ł¶ŧ←↓→øþ¨æſðđŋħł˝’»«¢„“”µ·…\"'"
isVerySpecial "ł¶ŧ←↓→øþ¨æſðđŋħł˝’»«¢„“”µ·…"
echo "Exit code: ${?}"
echo ""

#echo "The following string checks should exit with exit code '1'"
#echo "Executing command: 'isEmpty \"nom\"'"
#isEmpty "nom"
#echo "Exit code: ${?}"
#echo ""

#echo "Executing command: 'isNumeric \"abc\"'"
#isNumeric "abc"
#echo "Exit code: ${?}"
#echo ""

#echo "Executing command: 'isString \"123\"'"
#isString "123"
#echo "Exit code: ${?}"
#echo ""

#echo "Executing command: 'isLowercaseString \"NOM\"'"
#isLowercaseString "NOM"
#echo "Exit code: ${?}"
#echo ""

#echo "Executing command: 'isUppercaseString \"nom\"'"
#isUppercaseString "nom"
#echo "Exit code: ${?}"
#echo ""

#echo "Executing command: 'isAlphanumeric \"&(/§4\"'"
#isAlphanumeric "&(/§4"
#echo "Exit code: ${?}"
#echo ""

#echo "Executing command: 'isSpecial \"abaUF\"'"
#isSpecial "abaUF"
#echo "Exit code: ${?}"
#echo ""

#echo "Executing command: 'isSpecial \"aBadf287304\"'"
#isSpecial "aBadf287304"
#echo "Exit code: ${?}"
#echo ""

#echo "Executing command: 'isSpecial \"230470234¶ŧ←ŧ¶ø¶ŧ!\\\"§$\"'"
#isVerySpecial "230470234¶ŧ←ŧ¶ø¶ŧ!\"§$"
#echo "Exit code: ${?}"
#echo ""

#echo "Executing command: 'isSpecial \"adfhb¶ŧ←ŧ¶ø¶ŧ!\\\"§$\"'"
#isVerySpecial "adfhb¶ŧ←ŧ¶ø¶ŧ!\"§$"
#echo "Exit code: ${?}"
#echo ""
#echo ""

log_directory_path="/tmp/log"
declare -a application_name_array
application_name_array=("application1" "application2" "applicaton3" "application4")
prepareLogDirectory "${log_directory_path}" "750" application_name_array[@] "640"

echo "Do the directories have the access permissions 'drwxr-xr--' and the files '-rw-r-----'?"

for application_name in ${application_name_array[@]}
do
    log_directory="${log_directory_path}/${application_name}"
    log_file="${log_directory}/${application_name}.log"

    namei --long "${log_file}" | grep "${application_name}"
    echo ""
done

countDown "Cleaning up '/tmp/log/' in"
echo ""

# cleanup
rm --recursive --force --verbose "/tmp/log"
echo ""

# this should fail
#log_directory_path="/var/empty"
#declare -a application_name_array
#application_name_array=("application1" "application2" "applicaton3" "application4")
#prepareLogDirectory "${log_directory_path}" "750" application_name_array[@] "640"
#
#echo "Do the directories have the access permissions 'drwxr-xr--' and the files '-rw-r-----'?"
#
#for application_name in ${application_name_array[@]}
#do
#    log_directory="${log_directory_path}/${application_name}"
#    log_file="${log_directory}/${application_name}.log"
#
#    namei --long "${log_file}" | grep "${application_name}"
#    echo ""
#done
#
#countDown "Cleaning up '/tmp/log/' in"
#echo ""
#
## cleanup
#rm --recursive --force --verbose "/tmp/log"
#echo ""

createSystemLogEntry "this is a test"
createSystemLogEntry ""
echoC "" "" "yellow" "Please check this manually:"
echoC "" "" "yellow" "  - Check, if '/var/log/syslog' and '/var/log/messages' have the following entry:"
echoC "" "" "yellow" "    <short_month_name> <current_day> <HH>:<MM>:<SS> <hostname> ${SCRIPT_NAME}[<script_pid>]: ./${SCRIPT_NAME}: this is a test"
echoC "" "" "yellow" "    <short_month_name> <current_day> <HH>:<MM>:<SS> <hostname> ${SCRIPT_NAME}[<script_pid>]: ./${SCRIPT_NAME}: executed"
echoC "" "" "yellow" "    \$ sudo grep \"${SCRIPT_NAME}\" /var/log/{syslog,messages}"
echo ""
echo ""

setGraphicsPowerMethodAndProfile "profile" "high"
echo "Graphics card power method should be set to 'profile' and set to 'high':"
echo "Power method: $(< /sys/class/drm/card0/device/power_method)"
echo "Power profile: $(< /sys/class/drm/card0/device/power_profile)"
echo ""

countDown "Reverting graphics card power profile to 'low' in" "10"
echo ""

setGraphicsPowerMethodAndProfile "profile" "low"
echo "Graphics card power method should be set to 'profile' and set to 'low':"
echo "Power method: $(< /sys/class/drm/card0/device/power_method)"
echo "Power profile: $(< /sys/class/drm/card0/device/power_profile)"
echo ""

echoC "" "" "yellow" "Please check this manually:"
echoC "" "" "yellow" "  - Check, if '/var/log/syslog' and '/var/log/messages' have the following entry:"
echoC "" "" "yellow" "    <short_month_name> <current_day> <HH>:<MM>:<SS> <hostname> ${SCRIPT_NAME}[<script_pid>]: ./${SCRIPT_NAME}: set graphics card power profile to 'high'"
echoC "" "" "yellow" "    <short_month_name> <current_day> <HH>:<MM>:<SS> <hostname> ${SCRIPT_NAME}[<script_pid>]: ./${SCRIPT_NAME}: set graphics card power profile to 'low'"
echoC "" "" "yellow" "    \$ sudo grep \"${SCRIPT_NAME}\" /var/log/{syslog,messages}"
echo ""
echo ""

outputErrorAndExit "warning" "This is a warning message without exiting the script."
outputErrorAndExit "error" "This is an error message without exiting the script."
outputErrorAndExit "warning" "This is warning message, which exits the script with exit code '1'." "1"
outputErrorAndExit "error" "This is an error message, which exits the script with the imaginary exit code '24'." "24"
