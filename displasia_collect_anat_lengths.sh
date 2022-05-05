#!/bin/bash
source `which my_do_cmd`
fakeflag=""

imagesdir=/misc/nyquist/lconcha/displasia

table_of_lengths=${imagesdir}/table_of_lengths.txt

if [ -f $table_of_lengths ]; then rm $table_of_lengths;fi

for grp in CTRL BCNU
do
  for dr in ${imagesdir}/${grp}/*
  do
    rat=$(basename $dr)
    for dd in ${imagesdir}/${grp}/${rat}/*
    do
        day=$(basename $dd)
        for side in r l
        do
            for f_length in ${imagesdir}/${grp}/${rat}/${day}/derivatives/anat/*/tck/anat_${side}_out_resampled_native_length.txt
            do
            if [ -f $f_length ]
            then
            slice=$(echo $f_length | awk -F/ '{print $(NF-2)}')
            echolor cyan "[INFO] Working on $grp $rat $day $side $slice"
            transpose_table.sh $f_length > /tmp/data_$$.txt
            echo $grp $rat $day $side $(cat /tmp/data_$$.txt) >> $table_of_lengths
            fi
        done
        done
    done
  done
done

rm /tmp/data_$$.txt


echolor yellow "Done. Check out the file $table_of_lengths"