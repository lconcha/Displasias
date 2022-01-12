#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: dcortex

Creates a binary dilation from the input mask 
Default is a 2D coronal (xy) dilation 

Use:
    python mask_dilation.py input_mask n_iterations [ax_dilated]
"""
from os.path import join, dirname, basename, isfile
from sys import argv
import numpy as np
import nibabel as nib
from scipy.ndimage import binary_dilation, generate_binary_structure

#mask_file = "37A_l_grid_in.nii.gz"
#mask_path = "/data/Documentos/Maestría/LabC13/hoy/masks"
mask_file = argv[1]
n_iter = int(argv[2])
try:
    ax_dilated = argv[3] # 'x', 'y', 'xy'
except IndexError:
    ax_dilated = 'xy'


mask_path = dirname(mask_file)
mask_basename = basename(mask_file).split('.')[0]
mask_new_name = mask_basename + f'_dilatedx{n_iter}.nii.gz'

if isfile(join(mask_path, mask_new_name)):
    print('\n    mask_dilation.py: Dilated mask already exists\n')
    quit()

#img = nib.load(join(mask_path, mask_file))
img = nib.load(join(mask_file))
mask = img.get_fdata()
affine = img.affine

kernel_2d = np.zeros([3,3,3])

if ax_dilated == 'xy':
    kernel_2d[:,:,1] = generate_binary_structure(2, 1)
elif ax_dilated == 'x':
    kernel_2d[:,:,1] = np.array([[0,1,0],[0,1,0],[0,1,0]])
elif ax_dilated == 'y':
    kernel_2d[:,:,1] = np.array([[0,0,0],[1,1,1],[0,0,0]])

mask_dilated = binary_dilation(mask, structure=kernel_2d,
                               iterations=n_iter).astype(mask.dtype) 

# import matplotlib.pyplot as plt
# n_slice=14
# f, ax = plt.subplots(1,2)
# ax[0].imshow(mask[:,:,n_slice].T, origin="lower", cmap='Greys', aspect='equal')
# ax[1].imshow(mask_dilated[:,:,n_slice].T, origin="lower", cmap='Greys', aspect='equal')


#save
img_new = nib.Nifti1Image(mask_dilated, affine)
print(f'\n    mask_dilation.py: Creating dilated mask:\n{join(mask_path, mask_new_name)}')
nib.save(img_new, join(mask_path, mask_new_name) )


#import argparse







