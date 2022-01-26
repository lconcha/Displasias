#!/bin/bash
source `which my_do_cmd`


help(){
  echo "

How to use:
  `basename $0` <lines.nii.gz> <rat> <outfolder>


LU15 (0N(H4
INB UNAM
Jan 2022
lconcha@unam.mx
  "
}


if [ $# -lt 3 ]
then
  echolor red "Not enough arguments"
	help
  exit 2
fi


lines=$1
rat=$2
outfolder=$3


tmpDir=`mktemp -d`

plines=${outfolder}/lines.nii.gz


size1=$(mrinfo -size $lines | awk '{print $1}')
size2=$(mrinfo -size $lines | awk '{print $2}')
size3=$(mrinfo -size $lines | awk '{print $3}')


echolor yellow "sizes: $size1 $size2 $size3"
if [ $size2 -lt $size3 ]
then
  echolor cyan "Warning: size2 is larger than size3. Will permute dimensions"
  my_do_cmd mrconvert -axes 0,2,1 \
            -strides 1,2,3 \
            $lines \
            ${tmpDir}/plines_wtransf.nii.gz
  my_do_cmd mrtransform -identity ${tmpDir}/plines_wtransf.nii.gz ${tmpDir}/plines.nii.gz
        
else
  cp $lines ${tmpDir}/plines.nii.gz
fi

nSlices=$(mrinfo -size ${tmpDir}/plines.nii.gz | awk '{print $3}')
echolor yellow "There are $nSlices slices"

slicesToProcess=""
for s in `seq 1 $nSlices`
do
  ss=$(( $s -1 ))
  thismin=`mrconvert -quiet -coord 2 $ss ${tmpDir}/plines.nii.gz - | mrstats -output mean  -`
  if (( $(echo "$thismin > 0" |bc -l) ))
  then
    echolor yellow " Slice $ss has ROIs"
    slicesToProcess="$slicesToProcess $ss"
  fi
done


for s in $slicesToProcess
do
  mkdir $outfolder/${s}
  my_do_cmd mrcalc -quiet -force ${tmpDir}/plines.nii.gz 0 -mul ${tmpDir}/plane.nii 
  my_do_cmd mredit -quiet -force -plane 2 $s 1 ${tmpDir}/plane.nii
  my_do_cmd mrcalc -quiet -force ${tmpDir}/plane.nii ${tmpDir}/plines.nii.gz -mul ${tmpDir}/plines_one.nii.gz
  my_do_cmd expand_lines.sh ${tmpDir}/plines_one.nii.gz $rat $outfolder/${s}
done



#echolor cyan "Try running, for example:
# nii2streams.sh ${outfolder}/${rat}_l_inline.nii.gz ${outfolder}/${rat}_l_outline.nii.gz ${outfolder}/${rat}_l_inline.nii.gz ${outfolder} l $rat"

rm -fR $tmpDir