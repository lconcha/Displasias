#!/bin/bash
source `which my_do_cmd`


for mask in /misc/nyquist/paulinav/displasias/dwi_data/*/*/*/corticalmask.nii.gz
do
   grp=$(echo $mask | awk -F/ '{print $7}')
   day=$(echo $mask | awk -F/ '{print $8}')
   rat=$(echo $mask | awk -F/ '{print $9}')

   dwi=/misc/nyquist/paulinav/displasias/dwi_data/${grp}/${day}/${rat}/dwi/dwi_hibval_deb.nii.gz
   bvec=${dwi%.nii.gz}.bvec
   bval=${dwi%.nii.gz}.bval


   echo $grp $day $rat
   isOK=1
   for f in  $dwi $bvec $bval
   do
     if [ ! -f $f ]; then echolor red "Cannot find: $f"; isOK=0;fi
   done

   if [ $isOK -eq 0 ]; then continue;fi


  
   
   
   echolor green "Now fit NODDI"

   outdir=/misc/lauterbur2/lconcha/displasias/pau_AMICO/NODDI/${grp}/${day}/${rat}
   displasia_fit_noddi.py $dwi $bvec $bval $mask $outdir 
 
done