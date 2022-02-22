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
refimage=""

while getopts r: flag
do
    case "${flag}" in
        r) image=${OPTARG}
           refimage="-image2scanner $image"
           shift 2;;
    esac
done

tckin=$1
tckout=$2




tmpDir=`mktemp -d`

my_do_cmd $fakeflag tckconvert $tckin ${tmpDir}/lines-'[]'.txt

for f in ${tmpDir}/lines-*.txt
do
  ff=`basename $f`
  awk '{print $1,$3,$2}' $f > ${tmpDir}/p_${ff}
done


echo "refimage is $refimage"
my_do_cmd tckconvert \
  "$refimage" \
  ${tmpDir}/p_lines-'[]'.txt \
  $tckout


rm -fR $tmpDir