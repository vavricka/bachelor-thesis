#!/bin/sh
#script pro testovani vytizeni cpu
# $1 -- PID zkoumaneho procesu
#je nutno mit ve stejne slozce script genMessages.sh ktery loguje zpravy na syslog po nejakou dobu

sfile=/proc/$1/stat
if [ ! -r $sfile ]; then echo "pid $1 not found in /proc" ; exit 1; fi

start=$(cat $sfile| awk '{sum=$14+$15+$16+$17; print sum}')
time ./genMessages.sh 2> time_out && \
stop=$( cat $sfile| awk '{sum=$14+$15+$16+$17; print sum}')

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
