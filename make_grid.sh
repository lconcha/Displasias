#!/bin/bash

if [ "$1" == "-h" -o "$1" == "--help" -o "$1" == "" ]; then
  echo -e "\n	Usage: `basename $0` grid_in grid_mid [output_path]"
  echo -e "\n	Computes grid for the mincLaplace script."
  echo -e "\n	Returns '_grid_123.nii.gz' & '_grid_123.mnc'.\n"
  exit 0
fi

grid_in=$1
grid_mid=$2
out_folder=${3:-$(dirname $grid_in)}

echo -e "\n 	Making new grid in: '$out_folder'" # -e enables interpretation of backslash escapes
echo -e "\n 	Using: '$grid_in' & '$grid_mid'\n" 

# Area's default values:
in0=${4:-1}
mid=${5:-2}
out=${6:-3}

gridsufix=grid_${in0}${mid}${out}
grid_name=$(basename ${grid_in%_grid_in*})	# e.g. 37A_l

#echo $out_folder/${grid_name}_${gridsufix}.nii.gz

#for side in  l #r 	# left right

#grid_in=$(find $out_folder -type f -iname "*_${side}_grid_in.nii.gz")
#grid_mid=$(find $out_folder -type f -iname "*_${side}_grid_mid.nii.gz")

#rat_id=$(basename ${grid_in%%_*})

#if [ -f "${out_folder}/${rat_id}_${side}_${gridsufix}.nii.gz" ]
#then
#	echo -e "\n		Archivo '${rat_id}_${side}_${gridsufix}.nii.gz' ya existe.\n\n"

#elif [ -f "${rat_id}_${side}_grid_in.nii.gz" -a -f "${rat_id}_${side}_grid_mid.nii.gz" ]
#elif [ -f $grid_in -a -f $grid_mid ]

if [ -f "$out_folder/${grid_name}_${gridsufix}.nii.gz" ]
then
	echo -e "\n		File '${grid_name}_${gridsufix}.nii.gz' already exists.\n"
elif [ -f $grid_in -a -f $grid_mid ]
then
	#mrcalc ${rat_id}_${side}_grid_in.nii.gz 0 -mult $out -add base.nii
	mrcalc $grid_in 0 -mult $out -add ${out_folder}/base.nii

	mid_scalar="$(($mid-$out))"
	#mrcalc ${rat_id}_${side}_grid_mid.nii.gz $mid_scalar -mult base2.nii
	mrcalc $grid_mid $mid_scalar -mult ${out_folder}/base2.nii

	in_scalar="$(($in0-$out))"
	#mrcalc ${rat_id}_${side}_grid_in.nii.gz $in_scalar -mult base3.nii
	mrcalc $grid_in $in_scalar -mult ${out_folder}/base3.nii

	#mrcalc ${rat_id}_${side}_grid_in.nii.gz ${rat_id}_${side}_grid_mid.nii.gz -min $mid -mult base4.nii
	mrcalc $grid_in $grid_mid -min $mid -mult ${out_folder}/base4.nii

	#mrcalc base.nii base2.nii -add base3.nii -add base4.nii -add "${rat_id}_${side}_grid_${in0}${mid}${out}.nii.gz"
	a=${out_folder}/base.nii; b=${out_folder}/base2.nii
	c=${out_folder}/base3.nii; d=${out_folder}/base4.nii
	#mrcalc  $a $b -add $c -add $d -add ${out_folder}/${rat_id}_${side}_${gridsufix}.nii.gz
	mrcalc  $a $b -add $c -add $d -add $out_folder/${grid_name}_${gridsufix}.nii.gz

	gio trash ${out_folder}/base*.nii

	#nii2mnc ${out_folder}/${rat_id}_${side}_${gridsufix}.nii.gz ${out_folder}/${rat_id}_${side}_${gridsufix}.mnc
	nii2mnc $out_folder/${grid_name}_${gridsufix}.nii.gz $out_folder/${grid_name}_${gridsufix}.mnc

	echo -e "\n Grids '$out_folder/${grid_name}_${gridsufix}' (.mnc & .nii.gz) created in '$out_folder'\n"
else
	echo -e "\n	Error: files '$grid_in', '$grid_mid' missing.\n"
fi


