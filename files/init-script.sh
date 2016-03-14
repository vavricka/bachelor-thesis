#!/bin/sh

# File:            init-script.sh
# Version:         1.0
# Last Changed:    Mon 14 Mar 2016 22:23:00 CET
# Author:          David Vavricka

S_HDD_1="/mnt/hdd_1"
S_RSYSD="$S_HDD_1/sbin/rsyslogd"
S_RSYS_CONF="$S_HDD_1/rsyslog.conf"

S_MAC_PREFIX='set $!macaddr="'
I_MAC_NUM=$(sed 's/:/-/g' /sys/class/net/eth0/address)
S_MAC="${S_MAC_PREFIX}${I_MAC_NUM}\";"

killall klogd    && echo "klogd has been successfully killed"
killall syslogd  && echo "syslogd has been successfully killed"
killall rsyslogd && echo "rsyslogd has been successfully killed"

#IF path to rsyslog libraries isn't set -> fix it
if ! echo $LD_LIBRARY_PATH | grep -q "$S_HDD_1/lib"
then
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$S_HDD_1/lib"
fi

#Add Mac-addr of this STB to rsyslog.conf
sed -i "/${S_MAC_PREFIX}/c\\${S_MAC}" "$S_RSYS_CONF"

#Run rsyslog
if [[ "$1" == "debug" ]];
then
	echo "starting rsyslog with debug output..."
	"$S_RSYSD" -f "$S_RSYS_CONF" -n
else
	echo "starting rsyslog in normal mode..."
	"$S_RSYSD" -f "$S_RSYS_CONF"
fi
