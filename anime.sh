#!/bin/bash
MEDIA_PLAYER=mpv

function aniplay() {
    # Plays a file with MEDIA_PLAYER and marks as watched with anidb when it's done
    # If specified with --ask, zenity is used to ask whether the user wants to mark it as watched
    local ASK

    local play="$*"
    if [ "$1" == "--ask" ]; then
        local ASK="true"
        shift
        local play="$*"
    fi

    $MEDIA_PLAYER "$play"

    if [ "$ASK" ]; then
        zenity --question --title "aplay" --text "Mark as watched on anidb?"
        if [ $? -ne 0 ]; then
            return 0
        fi
    else
        return 0
    fi

    local out="1"
    while [[ "$out" -eq "1" ]]
    do
        anidb -aw "$play"
        local out=$?
        if [[ "$out" -eq "1" ]]
        then
            sleep 10
        fi
    done
}

function aplay() {
    # Tries to play an episode of an anime by searching for it with findanime
    # If there are several matches zenity is used to show a list of the matches

    local list=$( findanime "$1" "$2" )
    if (( ("$?" == 0) && $((`echo "$list" | wc -l` > 1)) ))
    then
        # The separator is required because sometimes zenity decides to return two of the same file
        local res=$( echo "$list" | zenity --separator @ --list --column "File" --width 600 --height 700 2> /dev/null | cut -d @ -f 1 )
        if [ -z "$res" ]; then
            return 1
        fi
    elif [ -z "$list" ] || [ "`echo "$list" | wc -l`" -le 0 ]; then
        echo 'Nothing found!'
        return 1
    else
        local res="$list"
    fi

    aniplay --ask "$res"
}

function findanime () {
    # Creates a list of anime files in ANIME_DIRS that matches name $1 and epno $2

    local ANIME_DIRS=( "$HOME/anime" "/media/c/Users/Gosha/Videos/Anime" "$HOME/cookie/home/gosha/anime" )
    local res=
    local tempres=
    for dir in "${ANIME_DIRS[@]}"
    do
        if [[ -d "$dir" ]]
        then
            local tempres=$( find $dir -xtype f | grep -i "$1" | grep -iP "((?<=[- _])|(?<=Ep))0*$2(?=[\[ _v.])" | sort )
            if [ ! -z "$res" ]
            then
                local res=$(echo -e "$res\n$tempres")
            else
                local res="$tempres"
            fi
        fi
    done
    echo "$res"
}

# If run with arguments, try to execute the arguments as functions.
# Maybe not very safe, but works with zsh when:
# DF="$HOME/.dotfiles"
# alias aplay="bash $DF/anime.sh aplay"

if [ ! -z "$*" ]
then
    command=$1
    shift
    $command $*
fi
