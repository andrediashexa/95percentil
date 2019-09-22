#!/bin/bash

user=root
password=PASSWORD
table=zabbix
nowmonth=$(date +%Y-%m)
month=$(date -d "$nowmonth-15 last month" '+%m')
year=$(date -d "$nowmonth-15 last month" '+%Y')
tmpdir=/tmp/testetmp
dir=/tmp/teste


mysql -u$user -p$password $table -e "select FROM_UNIXTIME(clock),round(value/1000000) from history_uint where itemid = $2 and FROM_UNIXTIME (clock, '%m') = $month AND FROM_UNIXTIME (clock, '%Y') = $year order by value DESC;" 2>/dev/null > $tmpdir
wc=$(cat $tmpdir | wc | awk {'print $1'})

if [ $1 = "report" ]; then
        tail -n +$(expr $wc / 100 \* 5 + 1) $tmpdir
        exit
fi

if [ $1 = "95" ]; then
        sed -n $(expr $wc / 100 \* 5 + 1)p $tmpdir | awk {'print $3'}
        exit
fi


echo "Invalid Argument"
