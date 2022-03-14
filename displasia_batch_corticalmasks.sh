#!/bin/bash
source `which my_do_cmd`
fakeflag=""

linesdir=/misc/nyquist/lconcha/displasia_streamlines_dwi

for f in ${linesdir}/*/*/*/lines.nii.gz
do
  ff=$(dirname $f)
  day=$(echo $ff | awk -F/ '{print $(NF-0)}')
  rat=$(echo $ff | awk -F/ '{print $(NF-1)}')
  grp=$(echo $ff | awk -F/ '{print $(NF-2)}')
  my_do_cmd $fakeflag displasia_prepare_corticalmasks.sh $grp $rat $day
done