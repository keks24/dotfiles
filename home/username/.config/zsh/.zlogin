# TODO:
#   - put everthing in functions, so the variables do not get exposed
#   - intercept missing commands
#
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

# define global variables
declare -a APPLICATION_NAME_LIST
## do not change the order of this list, only append new commands!
APPLICATION_NAME_LIST=(
                        "parcellite"
                        "ssh-agent"
                        "xautolock"
                      )
LOG_DIRECTORY="${HOME}/.log"

# log directory
## prepare log directories and files
for APPLICATION_NAME in ${APPLICATION_NAME_LIST[@]}
do
    if [[ ! -d "${LOG_DIRECTORY}/${APPLICATION_NAME}" ]]
    then
        \mkdir --parents --mode="750" "${LOG_DIRECTORY}/${APPLICATION_NAME}"
        \touch "${LOG_DIRECTORY}/${APPLICATION_NAME}/${APPLICATION_NAME}.log"
        \chmod 640 "${LOG_DIRECTORY}/${APPLICATION_NAME}/${APPLICATION_NAME}.log"
    else
        \continue
    fi
done
unset APPLICATON_NAME

# start applicatons
## application names must be hardcoded, in order to display the names in "jobs -l"
## align to openrc user services
if [[ -t 0 ]]
then
    for APPLICATION_NAME in ${APPLICATION_NAME_LIST[@]}
    do
        case "${APPLICATION_NAME}" in
            # parcellite (clipboard manager)
            "${APPLICATION_NAME_LIST[1]}")
                if ! \pgrep --euid="${USER}" "${APPLICATION_NAME}" >/dev/null
                then
                    \parcellite --no-icon >> "${LOG_DIRECTORY}/${APPLICATION_NAME}/${APPLICATION_NAME}.log" 2>&1 &!
                fi
                ;;

            # ssh-agent
            "${APPLICATION_NAME_LIST[2]}")
                if \pgrep --euid="${USER}" "${APPLICATION_NAME}" >/dev/null && [[ "${DISPLAY}" != "" && "${UID}" != "0" && -o login && "${TTY}" == "/dev/tty7" ]]
                then
                    \pkill --signal="SIGTERM" "${APPLICATION_NAME}"

                    # start "ssh-agent" with environment variables and save credentials for one hour
                    # further configurations are located at "/etc/ssh/ssh_config"
                    \eval $(\ssh-agent -st 1h) >> "${LOG_DIRECTORY}/${APPLICATION_NAME}/${APPLICATION_NAME}.log" 2>&1
                elif [[ "${DISPLAY}" == "" && "${UID}" != "0" && -o login && "${TTY}" == "/dev/tty7" ]]
                then
                    \eval $(\ssh-agent -st 1h) >> "${LOG_DIRECTORY}/${APPLICATION_NAME}/${APPLICATION_NAME}.log" 2>&1
                fi

                ;;

            # xautolock
            "${APPLICATION_NAME_LIST[3]}")
                if ! \pgrep --euid="${USER}" "${APPLICATION_NAME}" >/dev/null
                then
                    # start "physlock" after ten minutes to lock all screens; notify 30 seconds before
                    \xautolock -corners --00 -time 10 -locker "${HOME}/bin/locker" -notify 30 -notifier '${HOME}/bin/awesome_notifier "10" "critical" "xautolock" "Locking screen in 30 seconds..."' >/dev/null 2>&1 &!
                fi
                ;;

            *)
                \continue
        esac
    done
    unset APPLICATION_NAME

    # special case, if "gpg-agent" has been already started.
    if \pgrep --euid="${USER}" "gpg-agent" >/dev/null && [[ "${DISPLAY}" != "" && "${UID}" != "0" && -o login && "${TTY}" == "/dev/tty7" ]]
    then
        # reload "gpg-agent" with its loaded configuration files.
        \pkill --signal="SIGHUP" "gpg-agent"
    fi

    # startx (awesomewm)
    ## this part must be started at the very end!
    ## after autologin on "tty7", start "awesome" on "tty7"
    ## see also "${HOME}/.zshrc.local"
    if [[ "${DISPLAY}" == "" && "${UID}" != "0" && -o login && "${TTY}" == "/dev/tty7" ]]
    then
        \startx >> "${LOG_DIRECTORY}/startx/startx.log" 2>&1 &!
    fi
fi
