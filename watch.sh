#!/bin/bash

# Loop oneself with an argument to pass this test
if [ -z "$1" ]
then
    echo "Hello"
    clear
    next=""
    while true
    do
        # Double buffering lol
        next=`"$0" 1;`
        clear;
        echo -e "$next"
        sleep 5;
    done
fi

# Show a title in the format:
# "    TEXT        " with colors
title () {
    echo $* |
    awk '
    {
        str      = $1;
        fg       = 2;
        bg       = 233;
        color    = "\033[48;5;" bg "m" "\033[38;5;" fg "m";
        colorend = "\033[0m";
        startstr = "   "
        addstr   = " "
        fill     = ""
        fill_len      = 20
        for (i = 0; i < fill_len - length(str); i++) {
            fill = fill addstr;
        }
        printf ("\n%s%s%s %s%s\n",
                color, startstr, str, fill, colorend);
    }'
}

mem() {
    title "RAM"
    free -b | awk '
    BEGIN { OFS="\t" }
    $0 ~/Mem:/ {
        total      = $2;
    }

    $0 ~/buffers\// {
        used       = $3;
    }

    END {
        inperc     = 100*used/total;
        percstr    = "";
        percBarCnt = 51; # Width/3
        perc       = (inperc * percBarCnt)/100;
        percent    = perc / percBarCnt*100;

        cs = "\033[1;32m";
        if (percent > 60) {
            cs = "\033[0;33m"; # Yellow
        }
        if (percent > 80) {
            cs = "\033[1;31m"; # Bold red
        }
        ce = "\033[0m";

        count = 0;
        while (count++ != percBarCnt) {
            if (perc-- < 1) {
                percstr = percstr "░";
            } else {
                percstr = percstr "█";
            }
        }

        printf ("RAM: [%s%s%s]  %3.2f %%\n",
                cs ,percstr, ce, inperc);
        print "      " total/(1024^2) " - " used/(1024^2) " MB"


    }'
}

disks() {
    title "DISKS"
    df -h |
    awk '
    BEGIN { OFS="\t" }
    $1 ~/\/dev/ {
        full       = $0;
        disk       = $1;
        disk       = split (disk, a, "dev/")
        disk       = a[2];
        size       = $2;
        used       = $3;
        avail      = $4;
        inperc     = $5;
        mountedon  = $6;
        count      = 0 ;
        percstr    = "";
        percBarCnt = 26;
        perc       = ((inperc * percBarCnt) / 100);
        percent    = perc / percBarCnt*100;

        cs = "\033[1;32m";     # Green
        if (percent > 60) {
            cs = "\033[0;33m"; # Yellow
        }
        if (percent > 80) {
            cs = "\033[1;31m"; # Bold red
        }
        ce = "\033[0m";

        while (count++ != percBarCnt) {
            if (perc-- < 1) {
                percstr = percstr "░";
            } else {
                percstr = percstr "█";
            }
        }

        printf ("%5s, %8s [%s%s%s] %4s %4s left of %-4s\n",
                disk, mountedon, cs ,percstr, ce, inperc, avail, size);
    }'
}

agenda() {
    title "AGENDA"
    calcurse -n -c "$HOME/.calcurse/ap" | awk '
$0 ~ /\[/ {
    full = $1;
    cs   = "\033[1;32m";
    ce   = "\033[0m";
    hour = substr (full, 2, 2);
    min  = substr (full, 5, 2);
    if (hour == "00" && min <= 30) {
        cs = "\033[1;31m";
    }
    split ($0, a, "]");
    a[1] = cs a[1] "]" ce;
    print a[1] a[2];
}'
    calcurse -r2 -c "$HOME/.calcurse/ap" --format-apt='- %S %m\n'
}
torrents() {
    title "TORRENTS"
    # Remove duplicates, probabaly a bit slow when the file grows
    # bigger. First tac could probably be changed to a tail.
    TORRFILE=$HOME/torrlog
    TORRFILE=$HOME/cookie/home/gosha/torrlog
    tac $TORRFILE | awk 'BEGIN {FS="\t"} !a[$2]++' | tac | \
    tail -15 | awk 'BEGIN { FS = "\t" }
                                       { print "* " $2 }'
}

power() {
    BATPATH=/sys/class/power_supply/BAT0/power_now
    if [ -a  ]; then
        title "POWER"
        echo $(cat $BATPATH)/1000 | bc
    fi
}

sleep() {
    hour=$(date +%_H);
    sleeptime=8
    willwakeup=$(( ($hour + $sleeptime) % 24 ))
    wakeat=7
    gotobedat=$(( (24 + ($wakeat  - $sleeptime)) % 24 ))

    title "Sleep"
    echo "Bed now, wake at $willwakeup. Should go to bed at $gotobedat."
}

# Layout of output
sleep
mem
disks
power
#agenda
torrents
title "END"

echo "▖▗▘▙▚▛▜▝▞▟" | awk '
{
    srand();
    MAX = length($0);
    MIN = 0
    r = int (((rand () * (1 + MAX - MIN)) + MIN));
    printf ("%s", substr($0, r, 1));
}'
