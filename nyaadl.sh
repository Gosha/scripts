#!/bin/bash

# Download torrents from nyaa. Select using percol, download the
# torrents with wget.

searchnyaa.py "$@" | percol |\
while read line; do
    name=`echo "$line" | cut -f 1`
    link=`echo "$line" | cut -f 2`

    wget -O "$name.torrent" "$link"
done
