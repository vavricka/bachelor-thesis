#!/bin/ash
#set -x

#VARIABLES
I_NUM=0
S_PROG_NAME=""
S_HDD_1="/mnt/hdd_1"
S_RSYSD="$S_HDD_1/sbin/rsyslogd"
S_RSYS_CONF="$S_HDD_1/rsyslog.conf"

S_PREFIX='if $programname == '
S_MID=' and $syslogseverity > '

# Check number of parameters.
if [ $# -lt 1 ] || [ $(($#%2)) -ne 0  ]; then
    echo "Syntax Error, please pass even number of parameters."
    exit 1
fi

#loop through all parameters
for ARG in "$@"
    do
    # It's even argument (severity)
    if [ $(($I_NUM%2)) -ne 0  ]; then

		if ! echo $ARG | grep "^[0-9][0-9]*$" ; then
        	echo "$0: \"$ARG\" is not a number."
        	exit 1
    	fi

    	if [ $ARG -lt 0 ] || [ $ARG -gt 7 ] ; then
        	echo "$0: \"$ARG\" is not a valid severity. (It should be number 0-7)."
        	exit 1
    	fi

    	#if $programname == 'solid' and $syslogseverity-text > 'info'
    	S_COMPL_LINE="${S_PREFIX}'${S_PROG_NAME}'${S_MID}'$ARG'"

    	#If given APP-NAME is inside rsyslog.conf
    	if grep -q "${S_PREFIX}'${S_PROG_NAME}'${S_MID}" "$S_RSYS_CONF"
    	then
        	I_LINE_NUM=$(grep -n "${S_PREFIX}'${S_PROG_NAME}'${S_MID}" "$S_RSYS_CONF" | head -1 | cut -d : -f 1)

			(head -$(($I_LINE_NUM-1)) "$S_RSYS_CONF"; echo "$S_COMPL_LINE"; \
				tail -n +$(($I_LINE_NUM+1)) "$S_RSYS_CONF") > TMP_FILE && mv TMP_FILE "$S_RSYS_CONF";
		fi

    else
        S_PROG_NAME=$(echo $ARG | tr -d ' ')
    fi

    I_NUM=$(( $I_NUM+1 ))

done

# START RSyslog
#IF path to rsyslog libraries isn't set -> fix it
killall rsyslogd
if ! echo $LD_LIBRARY_PATH | grep -q "$S_HDD_1/lib"
then
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$S_HDD_1/lib"
fi

"$S_RSYSD" -f "$S_RSYS_CONF"
