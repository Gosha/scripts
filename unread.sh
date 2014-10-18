#!/bin/bash

cat ~/.comixlast | awk '
BEGIN { FS="\t" }
{
    if ($1 != $2) {
        printf( "(%3s/%3s) %s\n", $1,$2,$3);
    }
}'
