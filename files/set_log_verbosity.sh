##!/bin/sh

# File:            set_log_verbosity.sh
# Version:         1.0
# Last Changed:    Wed 30 Mar 2016 23:58:00 CET
# Author:          David Vavricka

S_HDD_1="/mnt/hdd_1"
S_RSYSD="$S_HDD_1/sbin/rsyslogd"
S_RSYS_CONF="$S_HDD_1/rsyslog.conf"

I_NUM=0
S_PROG_NAME=""
S_RSYS_CONF="rsyslog.conf"

S_PREFIX="if \$programname == \'"
S_MID="\' and \$syslogseverity-text > \'"

#ALL VALID SEVERITIES
declare -a A_SEVERITIES=(emerg alert crit err warning notice info debug)

containsElement () {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}

if [ ! -f "$S_RSYS_CONF" ]
    echo "$0: $S_RSYS_CONF is missing."
    exit 1
fi

# Check number of parameters.
if [ $# -lt 1 ] || [ $(($#%2)) -ne 0  ]; then
    echo "Syntax Error, please pass even number of parameters."
    exit 1
fi

#kill rsyslog
killall rsyslogd && echo "rsyslogd has been successfully killed"

#loop through all parameters
for ARG in "$@"
do
    # It's even argument (severity)
    if [ $(($I_NUM%2)) -ne 0  ]; then
        containsElement $ARG "${A_SEVERITIES[@]}"
        if [ $? -ne 0  ]; then
            echo "$0: \"$ARG\" is not a valid severity."
            #start rsyslog again
            "$S_RSYSD" -f "$S_RSYS_CONF"
            exit 1
        fi

        #if $programname == 'solid' and $syslogseverity-text > 'info'
        S_COMPL_LINE="${S_PREFIX}${S_PROG_NAME}${S_MID}$ARG\'"

        I_LINE_NUM=$(grep -n "${S_PREFIX}${S_PROG_NAME}${S_MID}" "$S_RSYS_CONF" | head -1 | cut -d : -f 1)

        (head -$(($I_LINE_NUM-1)) "$S_RSYS_CONF"; echo "$S_COMPL_LINE" | tr -d '\'; \
        tail -n +$(($I_LINE_NUM+1)) "$S_RSYS_CONF") > TMP_FILE && mv TMP_FILE "$S_RSYS_CONF";

    else
        S_PROG_NAME=$(echo $ARG | tr -d ' ')
    fi

    (( I_NUM++ ))
done

#start rsyslog again
"$S_RSYSD" -f "$S_RSYS_CONF"
