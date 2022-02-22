#!/bin/bash
source `which my_do_cmd`
fakeflag=""

help(){
echo "
`basename $0`[options] <in.tck> <out.tck>

Options:

-r <image.nii>      Provide an image from which to 
                           extract image2scanner tranformation.

LU15 (0n(H4
Feb 2022
INB UNAM
lconcha@unam.mx
"
}


if [ $# -lt 2 ]
then
  echolor red "Not enough arguments"
	help
  exit 2
fi


# defaults
image=""

while getopts r: flag
do
    case "${flag}" in
        r) image=${OPTARG}
        shift 2;;
        p) order=${OPTARG}
        shift 2;;
    esac
done


refimage=""
if [ ! -z "${image}" ]
then
  refimage="-image2scanner $image"
fi



tckin=$1
tckout=$2
refimage=$3

tmpDir=`mktemp -d`

my_do_cmd $fakeflag tckconvert $tckin ${tmpDir}/lines-'[]'.txt

for f in ${tmpDir}/lines-*.txt
do
  ff=`basename $f`
  awk '{print $1,$3,$2}' $f > ${tmpDir}/p_${ff}
done

my_do_cmd $fakeflag tckconvert ${tmpDir}/p_lines-'[]'.txt \
  $refimage \
  $tckout


rm -fR $tmpDir