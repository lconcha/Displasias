#!/bin/bash
source `which my_do_cmd`
fakeflag=""

#!/bin/bash



imagesdir=/misc/carr2/paulinav/Displasia_project


for grp in CTRL BCNU
do
  for dr in ${imagesdir}/${grp}/*
  do
    rat=$(basename $dr)
    for dd in ${imagesdir}/${grp}/${rat}/*
    do
      day=$(basename $dd)
      displasia_prepare_corticalmasks.sh $grp $rat $day
    done
  done
done
