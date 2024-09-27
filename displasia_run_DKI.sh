#!/bin/bash


dwi=$1
bval=$2
bvec=$3
mask=$4
outdir=$5

echo "start"

fcheck=${outdir}/mk.nii.gz
echolor cyan "Looking for $fcheck"
if [ ! -f $fcheck ]
then
    echolor cyan "  DKI output not found. Will run dipy_fit_dki"
    if [ ! -f $mask ]
    then
        echolor red "  Mask not found: $mask"
    else
        dipy_fit_dki \
        --b0_threshold 40 \
        --out_dir $outdir \
        $dwi $bval $bvec $mask
    fi
else
    echolor green "Kurtosis ran. File exists: $fcheck"
fi


# quick Quality Check, there should be few voxels with negative kurtosis
mk=${outdir}/mk.nii.gz
ak=${outdir}/ak.nii.gz
rk=${outdir}/rk.nii.gz
if [ -f $mk ]
then
    if [ -f ${outdir}/bad_mk.nii.gz ]
    then
        echolor green "QC ran, File exists: ${outdir}/bad_mk.nii.gz "
    else
        echolor cyan "Running quick QC"
        for f in $mk $ak $rk
        do
        mrcalc $f 0 -lt ${outdir}/bad_$(basename $f)
        done
    fi
fi
