import numpy as np
import sys

def encontrarDireccionStreamlines(args):
    # nombres de las ratas
    ratas = ["37A","37C","37D","38F","39A","39B","40A","40D","42A","42F","46A",
             "46B","46E","46G","46H","46I","46J","47A","47B","47C","47D","47E",
             "47I","47J","47K","48A","48G","48H","49G","49H","49I","52A","54D",
             "54E","55A","56B","57B"]

    ratascontajada = ["37A_l_14_", "37C_l_12_", "37D_l_13_", "38F_l_12_", "39A_l_12_",
                      "39B_l_13_", "40A_l_12_", "40D_l_11_", "42A_l_11_", "42F_l_12_",
                      "46A_l_12_", "46B_l_13_", "46E_l_12_", "46G_l_12_", "46H_l_12_",
                      "46I_l_12_", "46J_l_12_", "47A_l_12_", "47B_l_12_", "47C_l_11_",
                      "47D_l_11_", "47E_l_11_", "47I_l_12_", "47J_l_12_", "47K_l_12_",
                      "48A_l_12_", "48G_l_12_", "48H_l_12_", "49G_l_12_", "49H_l_11_",
                      "49I_l_12_", "52A_l_13_", "54D_l_12_", "54E_l_12_", "55A_l_12_",
                      "56B_l_13_", "57B_l_12_"]

    inicioDireccion = "/home/alonso/NAS/NAS/datos/aylin/displaciasCorticales/preproc/"
    inicioDireccionDerivatives = "/home/alonso/NAS/NAS/datos/aylin/displaciasCorticales/derivatives/"
    nombreCarpetaArchivos = args[0]
    medioDireccionCarpeta = "/ses-P30/dwi/" + nombreCarpetaArchivos
    finalDireccionPDD = args[1]
    finalDireccionNumComp = args[2]
    finalDireccionNiftiInput = args[3]

    finalDireccionNuevaParalela = finalDireccionNiftiInput[0:-4] + "_direccion_paralela.nii"
    finalDireccionNuevaPerpendicular = finalDireccionNiftiInput[0:-4] + "_direccion_perpendicular.nii"

    medioDireccionMascara = "/ses-P30/dwi/"
    finalDireccionMascara = "_mask_reshape.nii"

    from dipy.io.image import load_nifti, save_nifti
    import numpy as np
    import os
    from dipy.io.streamline import load_tractogram
    from dipy.tracking.utils import apply_affine
    from shapely.geometry import LineString, Point

    i=0

    for i in range(len(ratas)):
        #guardamos todas las direcciones que nos interesan
        direccionMascara = inicioDireccion + ratas[i] + medioDireccionMascara + ratas[i] + finalDireccionMascara
        direccionCarpeta = inicioDireccion + ratas[i] + medioDireccionCarpeta
        direccionPDD = direccionCarpeta + finalDireccionPDD
        direccionNumComp = direccionCarpeta + finalDireccionNumComp
        direccionNiftiInput = direccionCarpeta + finalDireccionNiftiInput
        direccionStreamlines = inicioDireccionDerivatives + ratas[i] + "/ses-P30/minc/tck/" + ratascontajada[i] + "out_resampled_10.tck"
        direccionReferencia = inicioDireccion + ratas[i] + "/ses-P30/dwi/" + ratas[i] + "_den_unr_ec_ub_clean.nii"
        direccionNuevaParalela = inicioDireccion + ratas[i] + medioDireccionCarpeta + finalDireccionNuevaParalela
        direccionNuevaPerpendicular = inicioDireccion + ratas[i] + medioDireccionCarpeta + finalDireccionNuevaPerpendicular
        
        #abrimos los nifti
        mask, affine = load_nifti(direccionMascara)
        numComp, affine = load_nifti(direccionNumComp)
        pdd, affinePDD = load_nifti(direccionPDD)
        niftiInput, affine = load_nifti(direccionNiftiInput)
        nuevaParalela, affine = load_nifti(direccionMascara) #esto se va a cambiar es solo para tener donde cambiarlo
        nuevaPerpendicular, affine = load_nifti(direccionMascara) #esto se va a cambiar es solo para tener donde cambiarlo
        #streamlines = nibabel.streamlines.load(direccionStreamlines)
        tractogram = load_tractogram(direccionStreamlines,direccionReferencia, bbox_valid_check=False)
        
        #buscamos la tajada que nos importa usando la mascara
        maxmask=0
        for i in range(mask.shape[2]):
            b = np.sum(mask[:,:,i])
            if b>maxmask:
                tajada = i
                maxmask=b

        # todos los streamlines 
        ST = tractogram.streamlines
        # numero de streamlines
        # print(len(ST))
        # recorrer por streamline
        for j in range(len(ST)):
            actualST = ST[j]
            direccionST = actualST[-1] - actualST[0]
            
            
        for i in range(mask.shape[0]): # recorrer voxeles
            for j in range(mask.shape[1]):
                if(mask[i,j,tajada] != 0):
                    # Esto es porque los streamlines estan en mm, entonces hay que cambiar todo a mm
                    lugar = apply_affine(affinePDD,[i,j,tajada])
                    # Para cada punto de la tajada se busca el streamline mas cercano y se guarda en slcercano
                    p = Point(lugar)
                    slcercano=0
                    menordist=10000
                    for k in range(50):
                        linea = LineString([ST[k*3][0],ST[k*3][-1]])
                        dist = p.distance(linea)
                        if dist < menordist:
                            menordist = dist
                            slcercano=k*3
                    # Se busca cual es el pdd paralelo al streamline y el perpendicular
                    cualpdd=0
                    cualpddperpendicular=0
                    # En vectST se guarda el vector en direccion des streamline
                    vectST=ST[slcercano][-1]-ST[slcercano][0]
                    # Esta es la direccion del primer vector a comparar con el streamline
                    vectpdd=np.array([pdd[i,j,tajada,0],pdd[i,j,tajada,1],pdd[i,j,tajada,2]])
                    # Estas formulas nos indican una medida para ver el angulo entre los dos vectores
                    nVectST=np.sqrt(vectST @ vectST)
                    nVectpdd=np.sqrt(vectpdd @ vectpdd)
                    vectST = vectST/nVectST
                    vectpdd = vectpdd/nVectpdd
                    norma = np.abs(vectST @ vectpdd)
                    normamenor = norma
                    # Si tenemos mas opciones de vectores con que comparar se hacen sus respectivas mediciones para ver cual
                    # es el mas paralelo y el mas perpendicular
                    if numComp[i,j,tajada]>1:
                        vectpdd=np.array([pdd[i,j,tajada,3],pdd[i,j,tajada,4],pdd[i,j,tajada,5]])
                        nVectpdd=np.sqrt(vectpdd @ vectpdd)
                        vectpdd = vectpdd/nVectpdd
                        if np.abs(vectST @ vectpdd) > norma:
                            cualpdd=1
                            norma = np.abs(vectST @ vectpdd)
                        if np.abs(vectST @ vectpdd) < normamenor:
                            cualpddperpendicular=1
                            normamenor = np.abs(vectST @ vectpdd)
                    if numComp[i,j,tajada]>2:
                        vectpdd=np.array([pdd[i,j,tajada,6],pdd[i,j,tajada,7],pdd[i,j,tajada,8]])
                        nVectpdd=np.sqrt(vectpdd @ vectpdd)
                        vectpdd = vectpdd/nVectpdd
                        if np.abs(vectST @ vectpdd) > norma:
                            cualpdd=2
                        if np.abs(vectST @ vectpdd) < normamenor:
                            cualpddperpendicular=2
                    # Se guarda en una matriz los nuevos valores en las direcciones deseadas
                    nuevaParalela[i,j,tajada]=niftiInput[i,j,tajada,cualpdd]
                    nuevaPerpendicular[i,j,tajada]=niftiInput[i,j,tajada,cualpddperpendicular]
        # Se guardan como niftis
        save_nifti(direccionNuevaParalela,nuevaParalela,affine)
        save_nifti(direccionNuevaPerpendicular,nuevaPerpendicular,affine)


def main():
    args = sys.argv[1:]
    if(len(args) != 4):
        print("Error, se necesitan 4 parametros. nombre de la carpeta de los archivos, nombrePDDs, nombre NumComp, nombre nifti input")
    encontrarDireccionStreamlines(args)

if __name__ == "__main__":
    main()
