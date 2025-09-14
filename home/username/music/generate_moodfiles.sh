#!/bin/bash
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
