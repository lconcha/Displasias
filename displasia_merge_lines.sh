#!/bin/bash



help(){
  echo "

To use:

`basename $0` <ol> <or> <il> <ir> <lines.nii[.gz]>


Merge the outlines and inlines of the cortex into a 3D volume.R

The output file will be the inputo of nii2streams, which expects
a 3D volume with the lines having values like this:

outline left  (ol) = 1
outline right (or) = 2
inline  left  (il) = 3
inline  right (ir) = 4

If you drew your lines as binary ROIs, you can use this script
to merge them into a single file.




LU15 (0N(H4
INB UNAM
August 2023
lconcha@unam.mx
  "
}


if [ $# -lt 5 ]
then
  echolor red "Not enough arguments"
	help
  exit 2
fi




ol=$1
or=$2
il=$3
ir=$4
outfile=$5


tmpDir=$(mktemp -d)

mrcalc $ol 1 -mul ${tmpDir}/01.nii
mrcalc $or 2 -mul ${tmpDir}/02.nii
mrcalc $il 3 -mul ${tmpDir}/03.nii
mrcalc $ir 4 -mul ${tmpDir}/04.nii


mrcat -axis 3 ${tmpDir}/0?.nii ${tmpDir}/lines4D.nii

mrmath -axis 3 ${tmpDir}/lines4D.nii sum $outfile
rm -fR $tmpDir
