#!/bin/bash



# imagesdir=/misc/carr2/paulinav/Displasia_project


# for grp in CTRL BCNU
# do
#   for dr in ${imagesdir}/${grp}/*
#   do
#     rat=$(basename $dr)
#     for dd in ${imagesdir}/${grp}/${rat}/*
#     do
#       day=$(basename $dd)
#       #echolor cyan "[INFO] Submitting job for $grp $rat $day"
#       mkdir -p ${imagesdir}/${grp}/${rat}/${day}/derivatives/dwi
#       mv -v ${imagesdir}/${grp}/${rat}/${day}/slice_* \
#              ${imagesdir}/${grp}/${rat}/${day}/derivatives/dwi/
#     done
#   done
# done


imagesdir=/misc/carr2/paulinav/Displasia_project
dwistreamlinesdir=/misc/nyquist/lconcha/displasia_streamlines_dwi

for grp in CTRL BCNU
do
  for dr in ${imagesdir}/${grp}/*
  do
    rat=$(basename $dr)
    for dd in ${imagesdir}/${grp}/${rat}/*
    do
      day=$(basename $dd)
      dirtomove=${dwistreamlinesdir}/${grp}/${rat}/${day}
      if [ ! -d $dirtomove ]
      then
        echolor red "[ERROR] WTF, cannot find $dirtomove"
      else
        destdir=${imagesdir}/${grp}/${rat}/${day}/derivatives/dwi/streamlines
        echolor cyan "[INFO] Found $dirtomove"
        echolor cyan "       Moving into $destdir"
        #mkdir -p $destdir
        #cp -rv ${dirtomove}/* ${destdir}/
        corticalmask=${dwistreamlinesdir}/corticalmasks/${rat}_${day}_${grp}_corticalmask.nii.gz
        if [ ! -f $corticalmask ]
        then
           echolor red "[ERROR] Cannot find corticalmask $corticalmask"
        else
           echo cp -v $corticalmask ${imagesdir}/${grp}/${rat}/${day}/derivatives/dwi/
        fi
      fi

    done
  done
done
