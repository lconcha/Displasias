

%addpath('/home/lconcha/software/mrtrix_matlab/matlab');
addpath('/home/inb/soporte/lanirem_software/mrtrix_3.0.4/matlab/')
addpath(genpath('/misc/lauterbur/lconcha/code/geom3d'))
%addpath(genpath('/home/lconcha/software/dicm2nii-master'))
%addpath /home/lconcha/software/Displasias/

f_tck         = 'dwi_l_out_resampled_native.tck';
%f_tck = 'permuted.tck'
f_PDD         = 'peaks3.nii';
%f_MRDS_ncomp  = 'afd_count.nii';
f_MRDS_ncomp   = 'one_two.nii';
f_AFD         = 'afd3.nii';
ff_values     = {f_AFD};
f_prefix      = './prefix';

VALUES = displasia_tckfixelsample_CSD(f_tck, f_PDD, f_MRDS_ncomp, ff_values, f_prefix);

