#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGDIR="/var/log/isil"
LOGFILE="$LOGDIR/isil_${TIMESTAMP}.log"
GCLOG="$LOGDIR/isil_gc_${TIMESTAMP}.log"
HEAPDUMP="$LOGDIR/isil_heapdump_${TIMESTAMP}.hprof"
HSERR="$LOGDIR/isil_hs_err_${TIMESTAMP}.log"

exec /usr/bin/java \
  -Xms2g \
  -Xmx24g \
  -XX:+UseG1GC \
  -XX:+HeapDumpOnOutOfMemoryError \
  -XX:HeapDumpPath="$HEAPDUMP" \
  -XX:ErrorFile="$HSERR" \
  -Xlog:gc*:file="$GCLOG":time,uptime,level,tags \
  -Dfile.encoding=UTF-8 \
  -jar /var/www/html/ISIL/isils/IsilSpring-0.0.1.war 2>&1 \
  | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }' >> "$LOGFILE"