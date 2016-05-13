#!/bin/sh

#KILL ALL SYSLOG DAEMONS
killall klogd    && echo "klogd has been successfully killed"
killall syslogd  && echo "syslogd has been successfully killed"
killall rsyslogd && echo "rsyslogd has been successfully killed"



#RSYS
S_HDD_1="/mnt/hdd_1"
S_RSYSD="$S_HDD_1/sbin/rsyslogd"
S_RSYS_CONF="$S_HDD_1/rsyslog.conf"
#IF path to rsyslog libraries isn't set -> fix it
if ! echo $LD_LIBRARY_PATH | grep -q "$S_HDD_1/lib"
then
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$S_HDD_1/lib"
fi
#SYSLOGD
#TODO

time "$S_RSYSD" -f "$S_RSYS_CONF" -n 2> time_out &


#RSYS
I_PID=$(ps -e | grep rsyslog | head -1 | awk '{print $1}')
#SYSLOGD
#TODO

echo $I_PID

sfile=/proc/$I_PID/stat
if [ ! -r $sfile ]; then echo "pid $I_PID not found in /proc" ; exit 1; fi


start=$(cat $sfile| awk '{sum=$14+$15+$16+$17; print sum}')

echo start $start
	
sleep 25 && echo c

stop=$( cat $sfile| awk '{sum=$14+$15+$16+$17; print sum}')

echo stop $stop

cat $sfile

#
killall rsyslogd

echo killall rsyslogd

sys_time=$(cat time_out | grep sys | awk '{print $3}' | tr -d 's')
user_time=$(cat time_out | grep user | awk '{print $3}' | tr -d 's')
cat time_out
rm -rf time_out

total_jiffies=$((stop-start))
echo \$total_jiffies $total_jiffies

get_mili_sec()
{
	 l_sec=$(echo $1 | cut -d'.' -f1)
	 l_mili_sec=$(echo $1 | cut -d'.' -f2)
	 echo $((l_mili_sec*10+l_sec*1000))
}

sys_time_mili_sec=$(get_mili_sec "$sys_time")
echo \$sys_time_mili_sec $sys_time_mili_sec
user_time_mili_sec=$(get_mili_sec "$user_time")
echo \$user_time_mili_sec $user_time_mili_sec
time_mili_sec=$((sys_time_mili_sec+user_time_mili_sec))
echo \$time_mili_sec $time_mili_sec


echo Realny cas scriptu MILISEC $time_mili_sec

cpuusage=$((total_jiffies*1000*1000/time_mili_sec))
echo cpuusage: $cpuusage
