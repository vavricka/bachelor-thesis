#!/bin/sh

# File:            log-rotate.sh
# Version:         1.0
# Last Changed:    Sat 12 Mar 2016 22:41:00 CET
# Author:          David Vavricka

NUM_BACKUPS="$1"

LOG_NAME="/var/log/messages"

if [ "$NUM_BACKUPS" -le "1" ]
then
    echo "$0: $1 is invalid argument, the number of backups must be greater than 1"
exit
fi

#Increment postfix of all backup files
num=$((NUM_BACKUPS))
while [ $num -ge 0 ]; do

    if [ -f "$LOG_NAME.$num" ]
        then
        mv -f "$LOG_NAME.$num" "$LOG_NAME.$((num+1))"
    fi
    num=$((num-1))
done

#If there is NUM_BACKUPS+1 files
if [ -f "$LOG_NAME.$((NUM_BACKUPS+1))" ]
then
    #Delete the oldest one
    rm -f "$LOG_NAME.$((NUM_BACKUPS+1))"
fi

mv -f $LOG_NAME $LOG_NAME.0
