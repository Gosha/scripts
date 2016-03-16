#!/bin/bash

# Download torrents from nyaa. Select using percol, download the
# torrents with wget.

if ! RESULT=$(searchnyaa.py "$@"); then
    exit 1
fi

if [ -z "$RESULT" ]; then
    >&2 echo "No results."
    exit
fi

function download_torrent() {
    name=`echo "$1" | cut -f 1`
    link=http:`echo "$1" | cut -f 2`

    wget -O "$name.torrent" "$link"
}

echo -n "$RESULT" | percol |\
    while read line; do
        download_torrent "$line"
    done
