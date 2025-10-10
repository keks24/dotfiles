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

set -euo pipefail

# define global variables
script_name="${0##/*}"
tmp_directory=$(/usr/bin/mktemp --directory "/tmp/${script_name}.XXXXXXXXXX")
error_file="${tmp_directory}/error"
# TODO: convert this to an array and provide a lot of suffixes
video_file_suffix="mp4"
hardware_acceleration="vdpau"

# TODO: create a list of files first and then create individual error files.
#       the latter, if and error has been found, if this is possible.
if /usr/bin/fd \
    --type="file" \
    --extension="${video_file_suffix}" \
    --exec \
    /usr/bin/ffmpeg \
        -v error \
        -hwaccel "${hardware_acceleration}" \
        -i "{}" \
        -map 0:1 \
        -f null \
        "-" \
    2>> "${error_file}"
then
    /bin/rm \
        --recursive \
        --force \
        "${tmp_directory}"
else
    echo -e "\e[01;31mErrors have been found! See '${error_file}'.\e[0m" >&2
    exit 1
fi
