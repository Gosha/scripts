#!/bin/bash
if [ ! -d ./save ];
then
    mkdir ./save;
fi

if [ -f ./cur ]
then
    feh --start-at `cat cur` --action 'mv %f save/' --action1 'echo %f > cur'
else
    feh --action 'mv %f save/' --action1 'echo %f > cur'
fi
