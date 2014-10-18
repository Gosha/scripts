#!/bin/bash
# Makes a list of every tumblr blog rss I'm following
# Uses cookies.txt exported from firefox

curl -s -b cookies.txt http://www.tumblr.com/following > ~/.following.html
grep -P 'class="avatar"' ~/.following.html | sed 's/></>\n</g' | grep -Po 'http://.*\/(?=")' | while read line
do
    echo ${line}rss;
done
