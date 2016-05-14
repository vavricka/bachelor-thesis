#!/bin/sh
# $1 -- PID zkoumaneho procesu

#CLK_TCKS
CLK_TCK=100
sfile=/proc/$1/stat
if [ ! -r $sfile ]; then
    echo "pid $1 not found in /proc" ; exit 1;
fi

#total time CPU (clock tick) daneho procesu a podprocesu
totalTime=$(cat $sfile| awk '{sum=$14+$15+$16+$17; print sum}')
echo totalTime: $totalTime
#uptime systemu (SECONDS)
upTime=$(cat /proc/uptime | tr '.' ' ' | awk '{print $1}')
echo upTime: $upTime
#Cas, kdy proc byl spusten (CLOCK TICKS)
startTime=$(cat $sfile| awk '{print $22}')
echo startTime: $startTime
#doba behu procesu v sekundach
seconds=$((upTime-(startTime/CLK_TCK)))
echo seconds: $seconds
################################
#dlouhodobe vytizeni cpu danym procesem
cpuUsage=$((totalTime*1000/seconds))
echo cpuUsage: $cpuUsage




