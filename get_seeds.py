#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Adjust seed line

@author: dcortex
"""
from os.path import join, basename
from os import chdir
import numpy as np
import nibabel as nib
from sklearn.neighbors import NearestNeighbors
import networkx as nx
from scipy.interpolate import splprep, splev

def sort_points(seeds):
    """
    Returns sorted 'seeds' (np.ndarray) by their nearest neighbors
    """
    if len(seeds)==0: return np.array([])
    clf = NearestNeighbors(n_neighbors=2).fit(seeds)
    G = clf.kneighbors_graph()  # sparse N x N matrix
    
    T = nx.from_scipy_sparse_matrix(G)
    
    paths = [list(nx.dfs_preorder_nodes(T, i)) for i in range(len(seeds))]

    mindist = np.inf
    minidx = 0
    
    for i in range(len(seeds)):
        p = paths[i]           # order of nodes
        ordered = seeds[p]    # ordered nodes
        # find cost of that order by the sum of euclidean distances between points (i) and (i+1)
        cost = (((ordered[:-1] - ordered[1:])**2).sum(1)).sum()
        if cost < mindist:
            mindist = cost
            minidx = i
    seeds = seeds[paths[minidx]]
    # Medial a lateral
    if seeds[0][1] < seeds[-1][1]: seeds = seeds[::-1]
    return seeds

def smooth_curve(x, y, s=0.5):
    tck, u = splprep([x, y], s=s)
    smooth_points = np.array(splev(u, tck)).T
    return smooth_points

def get_seeds_from_nii(f_name, subject, side='l', smooth=False, save=True, s=0.1, 
                        save_folder='~/Descargas',):
    lines_volume = nib.load(f_name).get_fdata()
    
    seeds_dict = {}
    for slice_n in range(10,16):
        
        sx, sy = np.array(np.nonzero(lines_volume[:,:,slice_n]))
        seeds = np.array([sx,sy]).T
        
        if len(seeds)==0: continue
        
        seeds = sort_points(seeds)
        if smooth: seeds = smooth_curve(*seeds.T, s=s)
        
        # Add z coordinate
        ones = np.ones([len(seeds), 1])
        seeds = np.concatenate((seeds, slice_n*ones), axis=1)[1:,:] 
        #               remove first entry because of reasons ^
        
        if save:
            seeds_name = f'{subject}_{side}_{slice_n}_seeds'
            if smooth: seeds_name += '_smooth'
            
            np.savetxt(join(save_folder, basename(seeds_name)+'.txt'), seeds)
            print(f'\n  Created file: {basename(seeds_name)}.txt in: {save_folder}')      

        seeds_dict[seeds_name] = seeds
        
    return seeds_dict
    
#_____________________________________________________________________________    


if __name__ == "__main__":
    import sys
    import subprocess
    from os.path import dirname
           
    #subject = sys.argv[1] # subject = '37A
    #side = 'l'
    
    #f_name = f'minc/{subject}_{side}_outline.nii' 
    f_name = sys.argv[1]
    out_dir = sys.argv[2]
    prefix = sys.argv[3]
    try:
        n_seeds = sys.argv[4]
    except IndexError:
        n_seeds = 150
    print(f'\n  Using {n_seeds} seeds')

    #subject = basename(f_name).split('_')[0]
    side = basename(f_name).split('_')[1]
    seeds = get_seeds_from_nii(f_name, subject=prefix, side=side, smooth=True, save=True,
                               s=10, save_folder=out_dir, )

    #out_dir = dirname(f_name)
    for seeds_name in list(seeds.keys()):
        
        convert1 = (f"tckconvert {join(out_dir, seeds_name)}.txt"
                    f" {join(out_dir, seeds_name)}.tck ") 
        # -voxel2scanner ../{subject}_x2.nii 
        resample = (f"tckresample -num_points {n_seeds} -nthreads 0"
                    f" {join(out_dir, seeds_name)}.tck"
                    f" {join(out_dir, seeds_name)}_resampled.tck")
        convert2 = (f"tckconvert {join(out_dir, seeds_name)}_resampled.tck"
                    f" {join(out_dir, seeds_name)}_resampled_[].txt")
        rename = (f"mv {join(out_dir, seeds_name)}_resampled_0000000.txt"
                  f" {join(out_dir, seeds_name)}_resampled.txt")
        for my_command in [convert1, resample, convert2, rename]:
            process = subprocess.Popen(my_command.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()
        
        print((f"\n  Created file: {join(out_dir, seeds_name)}_resampled"
               f"(txt & tck) in: {out_dir}\n"))

#!tckconvert {seeds_name}.txt {seeds_name}.tck -voxel2scanner ../{subject}_x2.nii
#!tckresample -num_points 150 -nthreads 0 {seeds_name}.tck {seeds_name}_resampled.tck
#!tckconvert {seeds_name}_resampled.tck {seeds_name}_resampled_[].txt
    
    sys.exit()







    