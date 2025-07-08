#!/bin/bash
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

declare -a command_array
command_array=(
                "/bin/cat"
                "/usr/bin/find"
                "/usr/bin/nproc"
                "/bin/rm"
                "/usr/bin/sort"
                "/usr/bin/xargs"
             )
checkCommands()
{
    unalias ${command_array[@]##*/} 2>/dev/null

    for current_command in "${command_array[@]}"
    do
        if [[ ! $(command -v ${current_command} 2>/dev/null) ]]
        then
            /bin/echo -e "\e[01;31mCould not find command '${current_command}'.\e[0m" >&2
            exit 1
        fi
    done
}

checkCommands

# define global directories
declare -a music_directory_array
declare -a playlist_file_array
music_directory_array=("../audiobooks" \
                       "../normal_music" \
                       "../unusual_music"\
                      )
music_filename_suffix="aac"
playlist_filename_suffix="m3u8"
playlist_all_filename="all.${playlist_filename_suffix}"
playlist_all_file="./${playlist_all_filename}"
playlist_file_array=("${playlist_all_file}" \
                     "./audiobooks.${playlist_filename_suffix}" \
                     "./normal_music.${playlist_filename_suffix}" \
                     "./unusual_music.${playlist_filename_suffix}" \
                    )
available_processors=$(/usr/bin/nproc --all --ignore="1")
xargs_max_args="1"

checkAndPromptExistingPlaylists()
{
    if [[ "${playlist_file_array[@]}" != "" ]]
    then
        local playlist_file
        local remove_playlist_files

        echo ""
        for playlist_file in "${playlist_file_array[@]}"
        do
            echo -e "\e[01;34m'${playlist_file}'\e[0m"
        done
        read -p $'\n\e[01;31mFound the above playlists in this directory. Remove them before generating new playlists? (y/N): \e[0m' remove_playlist_files >&2

        case "${remove_playlist_files:-n}" in
            "y"|"Y")
                echo -e "\e[01;31m"
                /bin/rm --force --verbose "${playlist_file_array[@]}"
                echo -ne "\e[0m"
                ;;

            "n"|"N")
                exit 1
                ;;
        esac
    fi
}

concatenateGeneratedPlaylistFiles()
{
    echo -e "\n\e[01;33mConcatenating all playlists to file: '${playlist_all_file}'.\e[0m\n" >&2
    /bin/cat "${playlist_file_array[@]}" > "${playlist_all_file}"
}

generatePlaylistFiles()
{
    local music_directory
    local playlist_file

    echo ""
    for music_directory in "${music_directory_array[@]}"
    do
        playlist_file="./${music_directory##*/}.${playlist_filename_suffix}"

        echo -e "\e[01;33mGenerating playlist file: '${playlist_file}'.\e[0m" >&2

        /usr/bin/find "${music_directory}" -type f -name "*.${music_filename_suffix}" -print0 \
            | /usr/bin/xargs --null --max-procs="${available_processors}" --max-args="${xargs_max_args}" echo \
            | /usr/bin/sort --ignore-case > "${playlist_file}"
    done
}

main()
{
    checkAndPromptExistingPlaylists

    generatePlaylistFiles

    concatenateGeneratedPlaylistFiles
}

main
