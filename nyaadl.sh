#!/bin/bash

# Download torrents from nyaa. Select using percol, download the
# torrents with wget.

if ! result=$(searchnyaa.py "$@"); then
    exit 1
fi

RESULTNUM=$(echo "$result" | wc -l)

if [ "$RESULTNUM" -eq 0 ]; then
    >&2 echo "No results."
    exit
fi

function download_torrent() {
    name=`echo "$1" | cut -f 1`
    link=`echo "$1" | cut -f 2`

    wget -O "$name.torrent" "$link"
}

echo -n "$result" | percol |\
    while read line; do
        download_torrent "$line"
    done
