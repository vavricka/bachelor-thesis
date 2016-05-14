#!/bin/sh
#script pro testovani vytizeni cpu
# $1 -- PID zkoumaneho procesu
#je nutno mit ve stejne slozce script genMessages.sh ktery loguje zpravy na syslog po nejakou dobu

sfile=/proc/$1/stat
if [ ! -r $sfile ]; then echo "pid $1 not found in /proc" ; exit 1; fi

start=$(cat $sfile| awk '{sum=$14+$15+$16+$17; print sum}')
time ./genMessages.sh 2> timeOut && \
stop=$( cat $sfile| awk '{sum=$14+$15+$16+$17; print sum}')

sysTime=$(cat timeOut | grep sys | awk '{print $3}' | tr -d 's')
userTime=$(cat timeOut | grep user | awk '{print $3}' | tr -d 's')
cat timeOut
rm -rf timeOut

clockTicks=$((stop-start))
echo \$clockTicks $clockTicks

getMilisec()
{
	 sec=$(echo $1 | cut -d'.' -f1)
	 miliSec=$(echo $1 | cut -d'.' -f2)
	 echo $((miliSec*10+sec*1000))
}

sysTimeMiliSec=$(getMilisec "$sysTime")
echo \$sysTimeMiliSec $sysTimeMiliSec
userTimeMiliSec=$(getMilisec "$userTime")
echo \$userTimeMiliSec $userTimeMiliSec
timeMiliSec=$((sysTimeMiliSec+userTimeMiliSec))
echo \$timeMiliSec $timeMiliSec

cpuUsage=$((clockTicks*1000*1000/timeMiliSec))
echo CPU Usage: $cpuUsage
