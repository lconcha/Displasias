#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: dcortex
"""
import nibabel as nib
import numpy as np
from scipy.ndimage.morphology import binary_fill_holes
from skimage import draw

def close_mask_in(im_slice_2d, side):
    """
    Returns the closed form of a '_{side}_inline.nii.gz' mask in numpy array
    and also the clipped array
    """
    new_slice = im_slice_2d.copy()
    
    x_no_0, y_no_0 = np.nonzero(im_slice_2d)
    if len(x_no_0) == 0: return new_slice, new_slice
    #breakpoint()
    x1 = x_no_0.min()   
    x2 = x_no_0.max()
    if side == "l":
        x_mid = x2; x_aux1 = x_mid - 9 + 1; x_aux2 = x2 + 1
    elif side == "r":
        x_mid = x1; x_aux2 = x_mid + 9; x_aux1 = x1
    
    y_mid = y_no_0[np.where(x_no_0==x_mid)[0]].min()
    y_min = y_no_0.min()
    
    # inferior line
    new_slice[x1:x2+1, y_min] = 1
    # medial line
    new_slice[x_mid, y_min:y_mid+1] = 1
    new_slice = binary_fill_holes(new_slice)
    # in_short array:
    other_slice = new_slice.copy() 
    other_slice[x_aux1:x_aux2, :] = 0
    
    return new_slice, other_slice

def endpoints(line_points):
    """
    Returns the 2 end-points of an array of points from a line
    """
    neighbors = []
    for p in line_points:
        aux = 0
        for q in line_points:
            if np.linalg.norm(p-q) == 1:
                aux += 1
        neighbors.append(aux)
    e_points = np.where(np.array(neighbors)==1)
    return line_points[e_points]

def close_mask_pair(im_slice_2d_in, im_slice_2d_out):
    new_slice = im_slice_2d_in + im_slice_2d_out
    
    p_in = np.array([*np.nonzero(im_slice_in)]).T
    p_out = np.array([*np.nonzero(im_slice_out)]).T
    if len(p_in) == 0: return new_slice
    
    e_in = endpoints(p_in)
    e_out = endpoints(p_out)
    #e_in.sort(axis=0); e_out.sort(axis=0)
    
    for i in [0, -1]:
        [x1, y1], [x2, y2] = e_in[i], e_out[i]
        line = draw.line(x1, y1, x2, y2)
        new_slice[line] = 1

    return binary_fill_holes(new_slice)

if __name__ == "__main__":
    import sys
    from os.path import exists, basename
    from argparse import ArgumentParser
   
    parser = ArgumentParser(
        description="""   Creates the 'in' and 'mid' closed masks from the
                        '*line.nii.gz' pair of masks.""")
    parser.add_argument('inline', type=str,
                        help="Nifti image of inline mask.")
    parser.add_argument('outline', type=str,
                        help="Nifti image of outline mask.")
    parser.add_argument('out_dir', type=str,
                        help="Output directory.")
    parser.add_argument('prefix', type=str, default=None,
                        help="String prefix for the output files.")
    parser.add_argument('-s', '--side', type=str, default=None,
                        help=("Hemisphere side (left 'l' or right 'r')."))
    args = parser.parse_args()
    
    inline = args.inline
    outline = args.outline
    out_dir = args.out_dir
    prefix = args.prefix
    s = args.side

    if s==None: s = inline.split('.')[0].split('_')[-2]

    # output filenames inline.split('.')[0][:-7]
    #grid_in = out_dir + "/" + prefix + s + "_grid_in.nii.gz"
    grid_in = f"{out_dir}/{prefix}_{s}_grid_in.nii.gz"
    grid_in9= f"{out_dir}/{prefix}_{s}_grid_in_short.nii.gz"
    grid_out= f"{out_dir}/{prefix}_{s}_grid_mid.nii.gz"
    filenames = [grid_in, grid_in9, grid_out]
    
    for file in filenames:
        if exists(grid_in):
            print(f"\n    {parser.prog}: File '{grid_in}' already exists"); sys.exit()
    
    line_in = nib.load(inline)
    line_out = nib.load(outline)
    
    
    array_in = line_in.get_fdata()
    array_out = line_out.get_fdata()
    
    array_grid_in = array_in.copy()
    array_grid_in_short = array_in.copy()
    array_grid_out = array_in.copy()
    
    for k in range(array_grid_in.shape[2]):
        im_slice_in = array_in[:,:,k]
        im_slice_out = array_out[:,:,k]
        
        closed_in, closed_in_short = close_mask_in(im_slice_in, side=s)
        closed_out = close_mask_pair(im_slice_in, im_slice_out)
        
        array_grid_in[:,:,k] = closed_in
        array_grid_in_short[:,:,k] = closed_in_short
        array_grid_out[:,:,k] = closed_out
        
    for i, a in enumerate([array_grid_in, array_grid_in_short, array_grid_out]):
        img = nib.Nifti1Image(a, line_in.affine)
        nib.save(img, filenames[i])
        print(f"\n  Created file: {filenames[i]}")
        
    sys.exit()

############## Tests
