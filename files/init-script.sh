#!/bin/sh

# File:            init-script.sh
# Version:         1.0
# Last Changed:    Sat 5 Mar 2016 17:07:00 CET
# Author:          David Vavricka

S_HDD_1="/mnt/hdd_1"
S_RSYSD="$S_HDD_1/sbin/rsyslogd"
S_RSYS_CONF="$S_HDD_1/rsyslog.conf"

killall klogd    && echo "klogd has been successfully killed"
killall syslogd  && echo "syslogd has been successfully killed"
killall rsyslogd && echo "rsyslogd has been successfully killed"

#IF path to rsyslog libraries isn't set -> fix it
if ! echo $(env | grep LD_LIBRARY_PATH) | grep -q "$S_HDD_1/lib"
then
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$S_HDD_1/lib"
fi

#Run rsyslog

if [[ "$1" == "debug" ]];
then
	echo "starting rsyslog with debug output..."
	"$S_RSYSD" -f "$S_RSYS_CONF" -n
else
	echo "starting rsyslog in normal mode..."
	"$S_RSYSD" -f "$S_RSYS_CONF"
fi
