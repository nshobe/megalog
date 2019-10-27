#!/bin/bash

set -eo pipefail
for FILE in `ls logs`; do
  FORMAT=$(head -1 logs/$FILE)
  #>output/$FILE.transform
  tail -n +5 logs/$FILE > output/$FILE.transform
  DATE=$(grep Date logs/$FILE | sed 's/Capture Date: //'| sed 's/"//g')
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
  FIELDS=$(head -3 logs/$FILE | tail -1 | sed 's/ //g' | sed 's/\t/ /g')
  ITERATION=0
  gawk -i inplace -v year=2019 -v month=09 -v day=30 -v hour=05 -v minute=04 -v second=04 '{add = $1; split(add,a,"."); $1 = strftime("%Y-%m-%dT%H:%M:%S", mktime(year" "month" "day" "hour" "minute" "second)  + a[1]);$1 = $1"."a[2]; print }' output/$FILE.transform
  #gawk -i inplace -v year=$YEAR -v month=$MONTH -v day=$MDAY -v hour=$LOGHOUR -v minute=$LOGMIN -v second=$LOGSEC '{add = $1; $1 = strftime("%Y-%m-%dT%H:%M:%S", mktime(year" "month" "day" "hour" "minute" "second) + add); print }' output/$FILE.transform
  #gawk -i inplace -v date=$LOGDATE -v zone=$ZONE '{$1 = date time $1"-"zone; print}' output/$FILE.transform
  for FIELD in $FIELDS; do
    ((ITERATION=ITERATION+1))
    echo "Starting the $ITERATION number field called $FIELD"
    gawk -i inplace -v field=$ITERATION -v header=$FIELD  '{$field = header"="$field; print}' output/$FILE.transform
  done
done
