#!/bin/bash
source `which my_do_cmd`

imtofix=$1
imref=$2
imout=$3


tmpDir=$(mktemp -d)


refdims=$(mrinfo -size $imref | tr ' ' ',')
refstrides=$(mrinfo -strides $imref | tr ' ' ',')

echolor yellow $refdims
echolor yellow $refstrides

my_do_cmd mrconvert -axes 0,2,1 -strides $refstrides $imtofix ${tmpDir}/permuted.nii
my_do_cmd mrgrid -size $refdims ${tmpDir}/permuted.nii regrid ${tmpDir}/regrid.nii
my_do_cmd fslcpgeom $imref ${tmpDir}/regrid.nii 
my_do_cmd mrconvert ${tmpDir}/regrid.nii $imout


rm -fR $tmpDir