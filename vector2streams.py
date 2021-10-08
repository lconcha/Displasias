#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: dcortex

New: python vector2streams.py minc_RGB seeds_txt img_ref stream_name
"""
import numpy as np
import nibabel as nib
from dipy.io.image import load_nifti
import matplotlib.pyplot as plt

def get_tck_list(segments):
    """
        Receives the flat list of segments of all streamlines
        Returns a list of lists. Each nested list is a streamline
    """
    lines = []
    current_line = []
    for s in segments:
        if current_line==[]:
            current_line.append(s[0])
            current_line.append(s[1])
            continue
        if np.array_equal(s[0], current_line[-1]):
            current_line.append(s[1])
        else:
            lines.append(np.array(current_line))
            current_line = []
    lines.append(np.array(current_line))
    return lines

def vectorfield2streams_2d(x, y, gX, gY, seeds, slice_n, side= 'l',
                           start_line='outline'):
    """"
        Returns list of ndarrays (streams in 2D)
    """
    if start_line=='outline': int_dir = 'forward'
    elif start_line=='inline': int_dir = 'backward'
    streams = []
    fig = plt.figure()
    for seed in seeds:
        strm = plt.streamplot(x.T[0], y[0],
                  gX[:,:,slice_n].T, gY[:,:, slice_n].T,
                  linewidth=1, density=20,
                  minlength=0.01,
                  start_points=seed.reshape([1,2]),
                  integration_direction=int_dir # 'forward','backward','both'
                  )
        segments = strm.lines.get_segments()
        lines = get_tck_list(segments)
        streams.append(lines[0])
    
    plt.close(fig)
    return streams


if __name__ == "__main__":
    import argparse
    import subprocess
    from os.path import dirname, isdir
    from dipy.io.streamline import load_tractogram, save_tractogram
    from dipy.io.stateful_tractogram import Space, StatefulTractogram, Origin

    parser = argparse.ArgumentParser(
                description='Creates streamlines from the given vector field.')
    parser.add_argument('minc_RGB', type=str,
                help='vector space created by mincLaplace (nifti)')
    parser.add_argument('seeds_txt', type=str,
                help='txt file with the seeds 3D coordinates')
    parser.add_argument('dwi_ref', type=str,
                help='DWI reference image to get the affine matrix (nifti)')
    parser.add_argument('stream_name', type=str,
                help='basename for new streamline files')
    
    #parser.print_help()
    args = parser.parse_args()

    # test values
    # minc_RGB = '37A_l_minc_RGB.nii.gz'
    # dwi_ref = '../37A_3d_ref.nii'
    # seeds_txt = "37A_l_14_seeds_smooth_resampled.txt"
    # stream_name = 'tck/37A_l_14_out'
    minc_RGB = args.minc_RGB
    dwi_ref = args.dwi_ref
    seeds_txt = args.seeds_txt
    stream_name = args.stream_name
    
    
    out_dir = dirname(stream_name)
    
    if not isdir(out_dir):
        print(f"\n    vector2streams.py: Directory '{out_dir}' doesn't exists\n")
        quit()
    
    img_RGB = nib.load(minc_RGB).get_fdata()
    _, affine = load_nifti(dwi_ref)
    seeds = np.loadtxt(seeds_txt)
    slice_n = int(seeds[0,-1])
  
    gX = img_RGB[:,:,:,0]
    gY = img_RGB[:,:,:,1]
    x, y = np.mgrid[0:gX.shape[0], 0:gX.shape[1]]
    
    streams_2d = vectorfield2streams_2d(x, y, gX, gY, seeds[:,:2], slice_n,
                                        side= 'r', start_line='outline')
    
    # add z-coordinate & save
    for i, s in enumerate(streams_2d):
        ones = np.ones([len(s), 1])
        v = np.concatenate((s, slice_n*ones, ones), axis=1)
        aux = np.diag([0.5,0.5,1,1])    # we were working on 2x size images
        new_s = (affine@aux@v.T).T
        #save
        j = f"{i:0{3}}" # zero padding
        np.savetxt(f"{stream_name}_{j}.txt", new_s[:,:3])
    
    # convert to .tck & resample
    convert = f"tckconvert {stream_name}_[].txt {stream_name}.tck"
    resample = (f"tckresample -num_points 20 -nthreads 0 {stream_name}.tck"
                f" {stream_name}_resampled.tck")
        
    for my_command in [convert, resample]:
        process = subprocess.Popen(my_command.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()

    # Get orthogonal streamlines
    tck_v = load_tractogram(f"{stream_name}_resampled.tck", dwi_ref,
                      #shifted_origin=False   # corner of the voxel (DEPRECATED)
                      to_origin=Origin('corner')
                      #   ^  NIFTI center, TRACKVIS corner (of the voxel)
                      )
    v_strms = tck_v.streamlines 

    #v_strms_data = v_strms.data.reshape([len(v_strms), *v_strms[0].shape])
    v_strms_data = v_strms.get_data().reshape([len(v_strms), *v_strms[0].shape])
    h_strms_data = v_strms_data.transpose(1,0,2)

    # for s in v_strms_data: plt.plot(*s[:,:2].T, color='blue')
    # for s in v_strms_data.transpose(1,0,2): plt.plot(*s[:,:2].T,color='gray')
    # plt.gca().axis('equal') 

    #sft_h = StatefulTractogram(h_strms_data, dwi_ref, Space.RASMM)
    sft_h = StatefulTractogram(h_strms_data, dwi_ref, space=Space.RASMM,
                               origin=Origin('corner'))
    save_tractogram(sft_h, f"{stream_name}_resampled_h.tck")



