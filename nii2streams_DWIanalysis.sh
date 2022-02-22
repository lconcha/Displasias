#!/bin/bash
source `which my_do_cmd`

help(){
  echo "

How to use:
  `basename $0` <lines_regrid.nii.gz> <dwi_regrid.nii.gz> <dwi_orig.nii.gz> <rat> <outfolder>


LU15 (0N(H4
INB UNAM
Jan 2022
lconcha@unam.mx
  "
}


if [ $# -lt 5 ]
then
  echolor red "Not enough arguments"
	help
  exit 2
fi



lines=$1
dwi_regrid=$2
dwi_orig=$3
rat=$4
outfolder=$5


if [ ! -d $outfolder ]
then
  echolor red "ERROR  Output directory does not exist: $outfolder"
  exit 2
fi



# prepare orientation and separate slices
nii2streams_prepareOrientation.sh $lines $dwi_regrid $rat $outfolder

for ss in `ls -d $outfolder/??`
do
  slice=`basename $ss`
  echolor yellow "Working on slice $slice"
  sides="l r"
  for side in $sides
  do
    my_do_cmd nii2streams.sh \
        ${outfolder}/${slice}/${rat}_${side}_inline.nii.gz \
        ${outfolder}/${slice}/${rat}_${side}_outline.nii.gz \
        ${outfolder}/${rat}_image.nii.gz \
        ${outfolder}/${slice} \
        $side \
        $rat
  done
done

# now put streamlines in native dwi space
for streamlinetck in ${outfolder}/*/tck/*.tck
do
  #echolor green "working on $streamlinetck"
  streamlinetck_native=${streamlinetck%.tck}_native.tck
  tck_permute_axes.sh \
    -r $lines \
    $streamlinetck $streamlinetck_native
done

