#!/bin/bash
#############################################################################
# Copyright 2022 Ramon Fischer                                              #
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

# correct filenames and directory names in order to be conform with the fat naming convention.
# the slash character is left out, since linux does not allow this character in filenames.
declare -a fat_illegal_character_array
fat_illegal_character_array=("<" ">" ":" "\"" "\\" "?" "*")
declare -a music_directory_array
music_directory_array=("audiobooks" "normal_music" "playlists" "podcasts" "record" "unusual_music")

for music_directory in "${music_directory_array[@]}"
do
    for fat_illegal_character in "${fat_illegal_character_array[@]}"
    do
        /usr/bin/find "${music_directory}" \
            -regextype posix-extended \
            \( \
                -type f -iregex ".*${fat_illegal_character}.*" \
                -or \
                -type d -iregex ".*${fat_illegal_character}.*" \
            \) \
            -exec /usr/bin/rename --verbose "${fat_illegal_character}" "_" "{}" +
    done
done
