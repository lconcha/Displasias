#!/bin/bash
source `which my_do_cmd`

if [ "$1" == "-h" -o "$1" == "--help" -o "$1" == "" ]; then
  echo -e "\n	Usage: `basename $0` grid (.mnc or .nii) [suffix_str] [alpha] [niter]"
  echo -e "\n	Runs 'my_MincLaplaceDist' on the given grid."
  echo -e "\n	Returns '_grid_123.nii.gz' & '_grid_123.mnc'.\n"
  exit 0
fi

input_grid=$1
suffix=${2:-''}
alpha=${3:-0.1}
niter=${4:-200}

# String before patern '_grid'
outputname=${input_grid%_grid*}_minc${suffix}

filename="${input_grid%.*}"
#extension="${input_grid##*.}"

#if [ ${input_grid: -4} == ".nii" ]
if [ -f ${outputname}_RGB.nii.gz ]
then
	echo -e "\n    '${outputname}_RGB.nii.gz' already exists \n"
	exit 1
fi

if [ ! -f ${filename}.mnc ] # if input isn't .mnc
then
	echo -e "\n    Converting '$input_grid' to .mnc format \n"
	nii2mnc ${filename}.nii
fi

echo -e "\n    Creating grid: '${outputname}' \n"
my_mincL=`dirname $0`"/my_MincLaplaceDist"

## Where the magic happens
echolor cyan "Running minclaplace!"
my_do_cmd $my_mincL \
  -i ${filename}.mnc \
  -o ${outputname} \
  -like ${filename}.mnc \
  -alpha $alpha \
  -max_iter $niter
echolor cyan "Finished running minclaplace."


mnc2nii ${outputname}_GradX.mnc ${outputname}_GradX.nii 
mnc2nii ${outputname}_GradY.mnc ${outputname}_GradY.nii
mnc2nii ${outputname}_GradZ.mnc ${outputname}_GradZ.nii

for f in ${outputname}_Grad?.nii 
do
  echo -e "\n    Copying geometry from ${filename}.nii to $f \n"
  my_do_cmd fslcpgeom ${filename}.nii $f
done


mrcat ${outputname}_GradX.nii ${outputname}_GradY.nii ${outputname}_GradZ.nii ${outputname}_RGB.nii.gz

gzip ${outputname}_GradX.nii; gzip ${outputname}_GradY.nii; gzip ${outputname}_GradZ.nii
gio trash ${outputname}_Grad*.mnc