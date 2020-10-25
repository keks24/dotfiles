# to do
# - put everthing in functions, so the variables do not get exposed
# - intercept missing commands
#
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

# custom - 20200619 - rfischer: start non-daemon processes in the background on boot ("/dev/tty1"). all variables are global to "zsh"!
# define global variables
declare -a APPLICATION_NAME_LIST
## do not change the order of this list, only append new commands!
APPLICATION_NAME_LIST=(parcellite ssh-agent xautolock)
LOG_DIRECTORY="${HOME}/.log"

# log directory
## prepare log directories and files
for APPLICATION_NAME in ${APPLICATION_NAME_LIST[@]}
do
    if [[ ! -d "${LOG_DIRECTORY}/${APPLICATION_NAME}" ]]
    then
        mkdir --parents --mode="750" "${LOG_DIRECTORY}/${APPLICATION_NAME}"
        touch "${LOG_DIRECTORY}/${APPLICATION_NAME}/${APPLICATION_NAME}.log"
        chmod 640 "${LOG_DIRECTORY}/${APPLICATION_NAME}/${APPLICATION_NAME}.log"
    else
        continue
    fi
done
unset APPLICATON_NAME

# start applicatons
## application names must be hardcoded, in order to display the names in "jobs -l"
for APPLICATION_NAME in ${APPLICATION_NAME_LIST[@]}
do
    case "${APPLICATION_NAME}" in
        # parcellite (clipboard manager)
        "${APPLICATION_NAME_LIST[1]}")
            if [[ ! $(pgrep --euid "$(id --user --name)" "${APPLICATION_NAME}") ]]
            then
                parcellite --no-icon >> "${LOG_DIRECTORY}/${APPLICATION_NAME}/${APPLICATION_NAME}.log" 2>&1 &!
            fi
            ;;

        # ssh-agent
        "${APPLICATION_NAME_LIST[2]}")
            if [[ ! $(pgrep --euid "$(id --user --name)" "${APPLICATION_NAME}") ]]
            then
                # start "ssh-agent" with environment variables and save passwords for one hour
                # further configurations are located at "/etc/ssh/ssh_config"
                eval $(ssh-agent -st 1h) >> "${LOG_DIRECTORY}/${APPLICATION_NAME}/${APPLICATION_NAME}.log" 2>&1
            fi
            ;;

        # xautolock
        "${APPLICATION_NAME_LIST[3]}")
            if [[ ! $(pgrep --euid "$(id --user --name)" "${APPLICATION_NAME}") ]]
            then
                # start "physlock" after ten minutes to lock all screens; notify 30 seconds before
                xautolock -corners --00 -time 10 -locker "/home/ramon/bin/locker" -notify 30 -notifier '/home/ramon/bin/awesome_notifier 10 critical "xautolock" "Locking screen in 30 seconds..."' >/dev/null 2>&1 &!
            fi
            ;;

        *)
            echo -e "\e[01;31mSomething went wrong.\e[0m"
    esac
done
unset APPLICATION_NAME

# startx (awesomewm)
## this part must be started at the very end!
## after autologin on "tty1", start "awesome" on "tty1"
if [[ "${DISPLAY}" == "" && "$(id --user)" != "0" && -o login && $(tty) == "/dev/tty1" ]]
then
    startx >> "${LOG_DIRECTORY}/startx/startx.log" 2>&1 &!
fi
