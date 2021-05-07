#!/bin/bash
portage_lib_directory_path="/var/lib/portage"
portage_world_file="${portage_lib_directory_path}/world"

if [[ ! -f "${portage_world_file}" ]]
then
    echo -e "\e[01;31mCould not find file '${portage_world_file}'.\e[0m" >&2
else
    for package_name in $(< "${portage_world_file}")
    do
        if /usr/bin/qdepends --query ${package_name} >/dev/null 2>&1
        then
            echo ""
            echo "Checking '${package_name}'..."

            if [[ -n "$(/usr/bin/emerge --pretend --quiet --depclean ${package_namei})" ]]
            then
                echo -e "\e[01;31mPackage '${package_name}' must stay in @world!\e[0m" >&2
            else
                echo -e "\e[01;32mPackage '${package_name}' can be deselected.\e[0m"
            fi
        fi
    done
fi
