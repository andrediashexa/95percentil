#!/bin/bash

user=root
password=PASSWORD
table=zabbix
nowmonth=$(date +%Y-%m)
month=$(date -d "$nowmonth-15 last month" '+%m')
year=$(date -d "$nowmonth-15 last month" '+%Y')
currmonth=$(date +%m)
curryear=$(date +%Y)
LASTMONTH=/tmp/lastmonth-$2
CURRENTMONTH=/tmp/currentmonth-$2


mysql -u$user -p$password $table -e "select FROM_UNIXTIME(clock),round(value/1000000) from history_uint where itemid = $2 and FROM_UNIXTIME (clock, '%m') = $month AND FROM_UNIXTIME (clock, '%Y') = $year order by value DESC;" 2>/dev/null > $LASTMONTH
wc=$(cat $LASTMONTH | wc | awk {'print $1'})

if [ $1 = "report" ]; then
        tail -n +$(expr $wc / 100 \* 5 + 1) $LASTMONTH
        exit
fi

if [ $1 = "fullreport" ]; then
        sed -n $(expr $wc / 100 \* 5 + 1)p $LASTMONTH | awk {'print $3'}
        exit
fi

if [ $1 = "95current" ]; then
        mysql -u$user -p$password $table -e "select FROM_UNIXTIME(clock),round(value/1000000) from history_uint where itemid = $2 and FROM_UNIXTIME (clock, '%m') = $currmonth AND FROM_UNIXTIME (clock, '%Y') = $curryear order by value DESC;" 2>/dev/null > $CURRENTMONTH
        sed -n $(expr $wc / 100 \* 5 + 1)p $CURRENTMONTH | awk {'print $3'}
        exit
fi

echo "Invalid Argument"
