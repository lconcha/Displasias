#!/bin/bash

metric=$1
rangemetric=$2
group=$3


mrview exampleSubject/fa.nii \
  -tractography.load exampleSubject/streamlines_50_10.tck \
  -tractography.tsf_load resultados_aylin/promedio_valores/${metric}_${group}.tsf \
  -tractography.tsf_range $rangemetric \
  -imagevisible false \
  -plane 2 \
  -tractography.slab -1 \
  -target -2.5,1.95,2.67 \
  -fov 8 \
  -noannotations \
  -capture.folder "snaps/" \
  -capture.prefix "${metric}_${group}_${rangemetric}" \
  -capture.grab \
  -exit

 
mrview exampleSubject/fa.nii   \
  -tractography.load exampleSubject/streamlines_50_10.tck \
   -tractography.tsf_load resultados_aylin/dcohen/${metric}_abs.tsf \
   -tractography.geometry points \
   -tractography.thickness 0.35 \
   -tractography.tsf_range 0,1 \
   -tractography.tsf_colourmap 4 \
  -tractography.load exampleSubject/streamlines_50_10.tck \
   -tractography.tsf_load resultados_aylin/pvalores/${metric}.tsf \
   -tractography.geometry points \
   -tractography.thickness 0.5 \
   -tractography.tsf_range 0,0.000001 \
   -tractography.tsf_thresh -1,0.05 \
   -tractography.tsf_colourmap 0  \
  -imagevisible false \
  -plane 2 \
  -tractography.slab -1 \
  -target -2.5,1.95,2.67 \
  -fov 8 \
  -noannotations \
  -capture.folder "snaps/" \
  -capture.prefix "${metric}_abs-cohen" \
  -capture.grab \
  -exit
