#!/bin/bash
############################################################################
# Copyright 2025 Ramon Fischer                                             #
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
declare -a music_directory_array
music_directory_array=(
                        "./audiobooks"
                        "./normal_music"
                        "./podcasts"
                        "./record"
                        "./unusual_music"
                      )

# functions
findAndConvertFiles()
{
    /usr/bin/fd \
        --type="file" \
        --ignore-case \
        --extension="amd" \
        --extension="flac" \
        --extension="it" \
        --extension="m4a" \
        --extension="mod" \
        --extension="mp3" \
        --extension="mp4" \
        --extension="mpc" \
        --extension="mtm" \
        --extension="nsf" \
        --extension="ogg" \
        --extension="opus" \
        --extension="rad" \
        --extension="s3m" \
        --extension="wav" \
        --extension="webp" \
        --extension="xm" \
        --print0 \
        --exec \
            ffmpeg \
                -i "{}" \
                -n \
                -c:a aac \
                -b:a 128k \
                -ar:a 44100 \
                -filter:a "volume=1.2" \
                "{//}/{/.}.aac" \
        "." \
        "${music_directory_array[@]}"
}

CleanUp
{
    echo "TODO: Cleanup files here."
}

main()
{
    findAndConvertFiles

    # TODO: Clean up files
    CleanUp
}

main
