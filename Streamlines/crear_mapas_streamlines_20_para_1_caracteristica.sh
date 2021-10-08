#!/bin/bash
if [ -n "$1" ]; then # Verificar que se mando un parametro
	ratascontajada=(37A_l_14_ 37C_l_12_ 37D_l_13_ 38F_l_12_ 39A_l_12_ 39B_l_13_ 40A_l_12_ 40D_l_11_ 42A_l_11_ 42F_l_12_ 46A_l_12_ 46B_l_13_ 46E_l_12_ 46G_l_12_ 46H_l_12_ 46I_l_12_ 46J_l_12_ 47A_l_12_ 47B_l_12_ 47C_l_11_ 47D_l_11_ 47E_l_11_ 47I_l_12_ 47J_l_12_ 47K_l_12_ 48A_l_12_ 48G_l_12_ 48H_l_12_ 49G_l_12_ 49H_l_11_ 49I_l_12_ 52A_l_13_ 54D_l_12_ 54E_l_12_ 55A_l_12_ 56B_l_13_ 57B_l_12_)
	ratas=(37A 37C 37D 38F 39A 39B 40A 40D 42A 42F 46A 46B 46E 46G 46H 46I 46J 47A 47B 47C 47D 47E 47I 47J 47K 48A 48G 48H 49G 49H 49I 52A 54D 54E 55A 56B 57B)
	inicioDireccionTck="/home/alonso/NAS/NAS/datos/aylin/displaciasCorticales/derivatives/"
	medioDireccionTck="/ses-P30/minc/tck/"
	# este es el nombre de los streamlines
	finalDireccionTck="out_resampled.tck"
	medioDireccionMapas="/ses-P30/mapas-streamlines-20/"
	# esta lista tiene los nombres que tendran al final los .txt
	finalesMapas=($2)
	inicioDireccionCaracteristicas="/home/alonso/NAS/NAS/datos/aylin/displaciasCorticales/preproc/"
	medioDireccionCaracteristicas="/ses-P30/dwi/"
	txt=".txt"
	# Aqui se guardan los nombres de como se llaman los nifti existentes que se quieren pasar a .txt como streamlines
	# finalNifti="out_dPar_SMT_dParMinMaxDTL1_Kaden_07_new/intra_totalUniformity_dPar_SMT_dParMinMaxDTL1_Kaden_Uniform_07.nii"
	finalNifti=$1
	# Esto es para cada rata, se tienen 37 ratas
	for i in {0..36}; do
		tck=$inicioDireccionTck${ratas[$i]}$medioDireccionTck${ratascontajada[$i]}$finalDireccionTck
		inicioCarpeta=$inicioDireccionCaracteristicas${ratas[$i]}$medioDireccionCaracteristicas
		intraNifti=$inicioCarpeta$finalNifti
		# se deja de esta manera porque se puede facilmente modificar la j para aceptar mas de 1 caracteristica
		direccionMapa=$inicioDireccionTck${ratas[$i]}$medioDireccionMapas${finalesMapas[0]}$txt
		tcksample -nthreads 0 $tck $intraNifti $direccionMapa
	done
else
	echo "Se necesita como parametro el nombre del archivo a convertir. En caso de estar dentro de una carpeta dentro de ../dwi/ añadirlo. "
fi
