#!/bin/bash
source `which my_do_cmd`

rat=$1
side=$2

tck=$(ls /misc/nyquist/dcortes_aylin/displaciasCorticales/derivatives/${rat}/ses-P30/minc/tck/${rat}_${side}_??_out_resampled.tck)
ntck=$(echo $tck | wc -l)
if [ ! $ntck -eq  1 ]
then
  echolor red "[ERROR] Found $ntck tck files. There should be only one."
  echo $tck
  exit 2
fi


img=$(ls /misc/nyquist/dcortes_aylin/displaciasCorticales/preproc/${rat}/ses-P30/dwi/take_on_mean.mif)
nimg=$(echo $img | wc -l)
if [ ! $nimg -eq  1 ]
then
  echolor red "[ERROR] Found $nimg image files. There should be only one."
  echo $img
  exit 2
fi


nslice=$(echo `basename $tck` | cut -d _ -f 3)
nstreamlines=$(tckinfo -count $tck | grep ' count:' | cut -d : -f 2 | sed 's/\s//g')

echolor yellow " Streamlines are in slice $nslice"
echolor yellow " There are $nstreamlines streamlines"

seq 1 ${nstreamlines} > /tmp/indices.txt

my_do_cmd mrview $img \
  -tractography.load $tck  \
  -tractography.tsf_load /tmp/indices.txt \
  -mode 1 \
  -voxel 0,0,${nslice}  \
  -plane 2

