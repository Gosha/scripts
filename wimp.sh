#!/bin/bash

function randomWimpOrgURL () {
    curl -Is www.wimp.com/random | grep -Po '(?<=Location: ).*/'
}

function wimpOrgFile() {
    curl $1 -Ls | grep 's1.addVariable("file"' | grep -oP '(?<=",").*(?=")'
}

function wmp() {
    smplayer -close-at-end `wimpOrgFile $1`
}

function rwmp() {
    URL=`randomWimpOrgURL`
    echo $URL
    wmp $URL
}

# If run with arguments, try to execute the arguments as functions.
# see anime.sh
if [ ! -z "$*" ]
then
    command=$1
    shift
    $command $*
fi
