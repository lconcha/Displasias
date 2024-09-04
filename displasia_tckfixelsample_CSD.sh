#!/bin/bash
source `which my_do_cmd` 
module load matlab

# this is  a wrapper for the matlab function,
# but it prepares the fixels in volume format.



Inputs=""
while getopts "t:f:p:" flag
do
    case "${flag}" in
        t) tck=${OPTARG};;
        f) fixels_dir=${OPTARG};;
        p) prefix=${OPTARG};;
    esac
done

#mInputs=`echo $Inputs | sed 's/ /,/g'`


# prepare fixels as volumes
fixels_afd=${fixels_dir}/afd.mif
if [ ! -f $fixels_afd ]
then
  echolor red "[ERROR] Cannot find file: $fixels_afd" 
fi

nComp=${fixels_dir}/afd_count.nii
afd_as_volume=${fixels_dir}/afd_as_volume.nii
peaks_as_volume=${fixels_dir}/peaks_as_volume.nii

fixel2voxel $fixels_afd count $nComp
fixel2voxel $fixels_afd none $afd_as_volume
fixel2peaks $fixels_dir $peaks_as_volume


mInputs="${afd_as_volume}"

matlabjobfile=$(mktemp -t).m
####################### matlab job
echo "

addpath('/home/inb/soporte/lanirem_software/mrtrix_3.0.4/matlab/')
addpath(genpath('/misc/lauterbur/lconcha/code/geom3d'))
addpath('/misc/mansfield/lconcha/software/Displasias');

  f_tck     = '$tck';
  f_PDD     = '$peaks_as_volume';
  f_ncomp   = '$nComp';
  ff_values = {'${mInputs}'};
  f_prefix  = '$prefix';
  
  
VALUES = displasia_tckfixelsample_CSD(f_tck, f_PDD, f_ncomp, ff_values, f_prefix);
exit

" > $matlabjobfile
###################### end of matlab job

cat $matlabjobfile

matlab -nodisplay -nosplash <$matlabjobfile

rm $matlabjobfile

