#!/bin/bash


boundsmahal="0,5"
for g in control bcnu
do
mrview exampleSubject/fa.nii \
  -tractography.load exampleSubject/streamlines_50_10.tck \
  -tractography.tsf_load resultados_aylin/promedio_distancia_${g}.tsf \
  -tractography.tsf_range $boundsmahal \
  -imagevisible false \
  -plane 2 \
  -tractography.slab -1 \
  -target -2.5,1.95,2.67 \
  -fov 8 \
  -noannotations \
  -capture.folder "snaps/" \
  -capture.prefix "avMahal_${g}_${boundsmahal}" \
  -capture.grab \
  -exit
done


mrview exampleSubject/fa.nii   \
  -tractography.load exampleSubject/streamlines_50_10.tck \
   -tractography.tsf_load resultados_aylin/dCohen.tsf \
   -tractography.geometry points \
   -tractography.thickness 0.35 \
   -tractography.tsf_range 0,2 \
   -tractography.tsf_colourmap 4 \
  -tractography.load exampleSubject/streamlines_50_10.tck \
   -tractography.tsf_load resultados_aylin/pvalores_pruebatstudent.tsf \
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
  -capture.prefix "abs-cohen_of_mahal" \
  -capture.grab \
  -exit
