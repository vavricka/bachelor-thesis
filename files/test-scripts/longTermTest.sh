#!/bin/sh
# $1 -- PID zkoumaneho procesu

#CLK_TCKS
HERTZ=100
sfile=/proc/$1/stat
if [ ! -r $sfile ]; then echo "pid $1 not found in /proc" ; exit 1; fi

#total time CPU (clock tick) daneho procesu a podprocesu
totaltime=$(cat $sfile| awk '{sum=$14+$15+$16+$17; print sum}')
echo totaltime: $totaltime
#uptime systemu (SECONDS)
uptime=$(cat /proc/uptime | tr '.' ' ' | awk '{print $1}')
echo uptime: $uptime
#Cas, kdy proc byl spusten (CLOCK TICKS)
starttime=$(cat $sfile| awk '{print $22}')
echo starttime: $starttime
#doba behu procesu v sekundach
seconds=$((uptime-(starttime/HERTZ)))
echo seconds: $seconds
################################
#dlouhodobe vytizeni cpu danym procesem
cpuusage=$((totaltime*1000/seconds))
echo cpuusage: $cpuusage




