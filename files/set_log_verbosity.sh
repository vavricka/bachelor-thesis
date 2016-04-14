#!/bin/ash
#set -x

#VARIABLES
I_NUM=0
S_PROG_NAME=""
S_RSYS_CONF="rsyslog.conf"

S_PREFIX='if $programname == '
S_MID=' and $syslogseverity-text > '

# Check number of parameters.
if [ $# -lt 1 ] || [ $(($#%2)) -ne 0  ]; then
    echo "Syntax Error, please pass even number of parameters."
    exit 1
fi

#loop through all parameters
for ARG in "$@"
    do
    FOUND=0

    # It's even argument (severity)
    if [ $(($I_NUM%2)) -ne 0  ]; then

    # Check if Argument is valid severity
    for i in emerg alert crit err warning notice info debug; do
    if [ "$i" = "$ARG" ] ; then
        FOUND=1
        break
    fi
    done

    if [ $FOUND -ne 1  ]; then
        echo "$0: \"$ARG\" is not a valid severity."
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
