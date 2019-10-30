#!/bin/bash

set -eo pipefail
CARS=$(ls logs)
for CAR in $CARS; do
  echo "Starting log folder $CAR" 
  FILES=$(ls logs/$CAR)
  if [ -z "$FILES" ]; then
    echo "No log files for $CAR, continuing"
    continue
  fi 
  for FILE in $FILES; do
    echo "Starting log file $FILE"
    FORMAT=$(head -1 logs/$CAR/$FILE| sed 's/"//g' | sed 's/\s+$//')
    if [[ "$FORMAT" =~ "MS3 Format 056" ]]; then
      echo "Log format understood. Continuing"
    else
      echo "Log fromat unknown. Exiting"
      exit 1
    fi
    mkdir -p output/$CAR
    mkdir -p /dev/shm/megalog
    tail -n +5 logs/$CAR/$FILE > /dev/shm/megalog/$FILE
    DATE=$(grep Date logs/$CAR/$FILE | sed 's/Capture Date: //'| sed 's/"//g')
    YEAR=$(echo $DATE | awk '{print $6}')
    ZONE=$(echo $DATE | awk '{print $5}')
    TIME=$(echo $DATE | awk '{print $4}')
    MDAY=$(echo $DATE | awk '{print $3}')
    MON=$(echo $DATE | awk '{print $2}')
    case $MON in
      Jan|jan)
        MONTH=01
        ;;
      Feb|feb)
        MONTH=02
        ;;
      Mar|mar)
        MONTH=03
        ;;
      Apr|apr)
        MONTH=04
        ;;
      May|may)
        MONTH=05
        ;;
      Jun|jun)
        MONTH=06
        ;;
      Jul|jul)
        MONTH=07
        ;;
      Aug|aug)
        MONTH=08
        ;;
      Sep|sep)
        MONTH=09
        ;;
      Oct|oct)
        MONTH=10
        ;;
      Nov|nov)
        MONTH=11
        ;;
      Dec|dec)
        MONTH=12
        ;;
    esac
    WDAY=$(echo $DATE | awk '{print $1}')
    LOGDATE="${YEAR} ${MON} ${MDAY}"
    LOGHOUR=$(echo $TIME | awk -F':' '{print $1}')
    LOGMIN=$(echo $TIME | awk -F':' '{print $2}')
    LOGSEC=$(echo $TIME | awk -F':' '{print $3}')
    FIELDS=$(sed -n '3p' logs/$CAR/$FILE | sed 's/ //g; s/\t/ /g; s/:/-/g; s/\./-/g')
    ITERATION=0
    gawk -i inplace \
      -v year=$YEAR -v month=$MONTH -v day=$MDAY -v hour=$LOGHOUR -v minute=$LOGMIN -v second=$LOGSEC \
      '{add = $1; split(add,a,"."); \
        $1 = strftime("%Y-%m-%dT%H:%M:%S", \
          mktime(year" "month" "day" "hour" "minute" "second)  + a[1]); \
        $1 = $1"."a[2]; print \
      }' /dev/shm/megalog/$FILE
    sed -i '/^MARK/d' /dev/shm/megalog/$FILE
    for FIELD in $FIELDS; do
      ((ITERATION=ITERATION+1))
      echo "Starting the $ITERATION number field called $FIELD"
      gawk -i inplace -v field=$ITERATION -v header=$FIELD  '{$field = header"="$field; print}' /dev/shm/megalog/$FILE
    done
    mv /dev/shm/megalog/$FILE output/$CAR/$FILE
    rm -f logs/$CAR/$FILE
    echo "Completed: $FILE"
  done
  echo "Completed: $CAR"
done
echo "Done"
