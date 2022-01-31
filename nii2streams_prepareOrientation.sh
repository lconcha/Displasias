#!/bin/bash
source `which my_do_cmd`


help(){
  echo "

How to use:
  `basename $0` <lines.nii.gz> <t2.nii.gz> <rat>  <outfolder>


LU15 (0N(H4
INB UNAM
Jan 2022
lconcha@unam.mx
  "
}


if [ $# -lt 4 ]
then
  echolor red "Not enough arguments"
	help
  exit 2
fi


lines=$1
t2=$2
rat=$3
outfolder=$4

if [ ! -d $outfolder ]
then
  echolor red "ERROR Outfolder does not exist: $outfolder"
  exit 2
fi


tmpDir=`mktemp -d`


# first make sure we have the same transformation matrices between t2 and lines
my_do_cmd mrconvert -quiet $t2 ${tmpDir}/t2.nii.gz 
my_do_cmd mrconvert -quiet $lines ${tmpDir}/lines.nii.gz
my_do_cmd fslcpgeom ${tmpDir}/lines.nii.gz ${tmpDir}/t2.nii.gz
lines=${tmpDir}/lines.nii.gz
t2=${tmpDir}/t2.nii.gz


# modify strides
plines=${outfolder}/lines.nii.gz
size1=$(mrinfo -size $lines | awk '{print $1}')
size2=$(mrinfo -size $lines | awk '{print $2}')
size3=$(mrinfo -size $lines | awk '{print $3}')
echolor yellow "sizes: $size1 $size2 $size3"
if [ $size2 -lt $size3 ]
then
  echolor cyan "Warning: size2 is larger than size3. Will permute dimensions of lines"
  my_do_cmd mrconvert -quiet -axes 0,2,1 \
            -strides 1,2,3 \
            $lines \
            ${tmpDir}/plines_wtransf.nii.gz
  my_do_cmd mrtransform -quiet -identity ${tmpDir}/plines_wtransf.nii.gz ${tmpDir}/plines.nii.gz
  echolor cyan "Warning: Also permuting dimensions of t2"
  my_do_cmd mrconvert -quiet -axes 0,2,1 \
            -strides 1,2,3 \
            $t2 \
            ${tmpDir}/t2_wtransf.nii.gz
  my_do_cmd mrtransform -quiet -identity ${tmpDir}/t2_wtransf.nii.gz ${outfolder}/${rat}_t2.nii.gz
        
else
  cp $lines ${tmpDir}/plines.nii.gz
  cp $t2 ${outfolder}/${rat}_t2.nii.gz
fi


# make sure the T2 has the same geometry
#my_do_cmd mrconvert -quiet $t2 ${outfolder}/${rat}_t2.nii.gz
#my_do_cmd fslcpgeom ${tmpDir}/plines.nii.gz ${outfolder}/${rat}_t2.nii.gz





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


mrcat -quiet -axis 3 \
  $outfolder/??/${rat}_?_inline.nii.gz \
  $outfolder/??/${rat}_?_outline.nii.gz - | \
  mrmath -quiet -axis 3 - max ${outfolder}/lines.nii.nii.gz

#echolor cyan "Try running, for example:
# nii2streams.sh ${outfolder}/${rat}_l_inline.nii.gz ${outfolder}/${rat}_l_outline.nii.gz ${outfolder}/${rat}_l_inline.nii.gz ${outfolder} l $rat"

rm -fR $tmpDir