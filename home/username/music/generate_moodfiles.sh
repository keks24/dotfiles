#!/bin/bash
############################################################################
# Copyright 2026 Ramon Fischer                                             #
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

NUMCPU="$(grep "^processor /proc/cpuinfo" | wc -l)"

find *_music -type f -regextype posix-awk -iregex '.*\.(aac|flac|mp3|ogg|wma)' | while read i
do
    while [ $(jobs -p | wc -l) -ge ${NUMCPU} ] ; do
        sleep 0.1
    done

    TEMP="${i%.*}.mood"
    OUTF=$(echo "${TEMP}" | sed 's#\(.*\)/\([^,]*\)#\1/.\2#')

    if [ ! -e "${OUTF}" ]
    then
        moodbar -o "${OUTF}" "${i}" &
    fi
done
