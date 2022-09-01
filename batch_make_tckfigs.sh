#!/bin/bash

var=0
while read line;
do
  metric=`echo $line | awk '{print $1}'`
  bounds=`echo $line | awk '{print $2}'`
  echo "$var - $metric - $bounds"
  for g in control bcnu
  do
    ./fn_makesnaps.sh $metric $bounds $g
  done
  ((var++))
done < <(cat metrics_and_ranges.txt)
