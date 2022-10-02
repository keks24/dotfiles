#!/bin/bash
#############################################################################
# Copyright 2021 Ramon Fischer                                              #
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

declare -a command_array
command_array=("/usr/bin/espeak" "/usr/bin/find" "/home/ramon/git/external/github.com/rockbox/tools/rbspeexenc" "/bin/rm")
checkCommands()
{
    unalias "${command_array[@]##*/}" >/dev/null 2>&1

    for current_command in "${command_array[@]}"
    do
        if ! command -v ${current_command} >/dev/null 2>&1
        then
            echo -e "\e[01;31mCould not find command '${current_command}'.\e[0m" >&2
            echo -e "\e[01;33mIf 'rbspeexenc' is missing, it must be compiled like so:\e[0m" >&2
            echo -e "\e[01;33mmake --directory='/home/ramon/git/external/github.com/rockbox/tools/rbspeex'\e[0m" >&2
            exit 1
        fi
    done
}

checkCommands

# define global variables
declare -a music_directory_array
music_directory_array=("audiobooks" "normal_music" "playlists" "podcasts" "record" "unusual_music")
music_filename_suffix="aac"
rockbox_directory_filename="_dirname"
rockbox_filename_suffix="talk"
rockbox_directory_voice_file="${rockbox_directory_filename}.${rockbox_filename_suffix}"
rockbox_voice_quality_value="8"
rockbox_voice_complexity_value="10"
rockbox_voice_volume_value="1.0"
espeak_directory_filename="${rockbox_directory_filename}"
# must be a mono 16 bit wav file!
# see also "rbspeexenc --help"
espeak_filename_suffix="wav"
espeak_directory_voice_file="${espeak_directory_filename}.${espeak_filename_suffix}"
espeak_reading_speed="125"
# uncomment for debugging. also uncomment at the end of the loop
#debug_counter="1"

for music_directory in "${music_directory_array[@]}"
do
    if [[ ! -d "${music_directory}" ]]
    then
        echo -e "\e[01;31mCould not find directory: '${music_directory}'." >&2
        exit 1
    fi
done

main()
{
    local directory_path
    while read -r directory_path
    do
        echo "Entering directory: '${directory_path}'."
        pushd "${directory_path}" >/dev/null

        local directory_name="${directory_path##*/}"
        local music_file_list=$(/usr/bin/find . -maxdepth 1 -type f -name "*.${music_filename_suffix}" -printf "%f\n")

        # create ".wav" files for rockbox's "rbspeexenc" program and encode them to ".talk" files
        if [[ ! -f "${rockbox_directory_voice_file}" ]]
        then
            echo -e "    \e[01;34mGenerating\e[0m\t'espeak' voice file: '${espeak_directory_voice_file}'."
            /usr/bin/espeak -s "${espeak_reading_speed}" -b 1 -z -w "${espeak_directory_voice_file}" -- "${directory_name}"

            echo -e "    \e[01;35mEncoding\e[0m\t'espeak' voice file: '${espeak_directory_voice_file}' to 'rockbox' voice file: '${rockbox_directory_voice_file}'."
            "/home/ramon/git/external/github.com/rockbox/tools/rbspeexenc" \
                -q "${rockbox_voice_quality_value}" \
                -c "${rockbox_voice_complexity_value}" \
                -v "${rockbox_voice_volume_value}" \
                "${espeak_directory_voice_file}" "${rockbox_directory_voice_file}"

            echo -e "    \e[01;31mRemoving\e[0m\t'espeak' voice file: '${espeak_directory_voice_file}'."
            /bin/rm --force -- "${espeak_directory_voice_file}"
        fi

        if [[ "${music_file_list}" != "" ]]
        then
            local music_file
            while read -r music_file
            do
                local rockbox_voice_file="${music_file}.${rockbox_filename_suffix}"

                if [[ ! -f "${rockbox_voice_file}" ]]
                then
                    local espeak_voice_file="${music_file}.${espeak_filename_suffix}"

                    echo -e "    \e[01;34mGenerating\e[0m\t'espeak' voice file: '${espeak_voice_file}'."
                    /usr/bin/espeak -s "${espeak_reading_speed}" -b 1 -z -w "${espeak_voice_file}" -- "${music_file/\.${music_filename_suffix}/}"

                    echo -e "    \e[01;35mEncoding\e[0m\t'espeak' voice file: '${espeak_voice_file}' to 'rockbox' voice file: '${rockbox_voice_file}'."
                    "/home/ramon/git/external/github.com/rockbox/tools/rbspeexenc" \
                        -q "${rockbox_voice_quality_value}" \
                        -c "${rockbox_voice_complexity_value}" \
                        -v "${rockbox_voice_volume_value}" \
                        "${espeak_voice_file}" "${rockbox_voice_file}"

                    echo -e "    \e[01;31mRemoving\e[0m\t'espeak' voice file: '${espeak_voice_file}'."
                    /bin/rm --force -- "${espeak_voice_file}"
                fi
            done <<< "${music_file_list}"

            # wildcards are dangerous!
            #/bin/rm --force -- *."${espeak_filename_suffix}"
        fi

        echo -e "Leaving directory: '${directory_path}'.\n"
        popd >/dev/null

        # uncomment for debugging. cleanup must be done manually afterwards!
        #if [[ "${debug_counter}" == "10" ]]
        #then
        #    break
        #fi
        #(( debug_counter++ ))
    done < <(/usr/bin/find "${music_directory_array[@]}" -type d)
}

main
