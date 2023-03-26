

addpath('/home/lconcha/software/mrtrix_matlab/matlab');
addpath(genpath('/home/lconcha/software/dicm2nii-master'))
addpath /home/lconcha/software/Displasias/



f_tck         = '/datos/syphon/displasia/testMRDS/dwi/one.tck';
f_PDD         = '/datos/syphon/displasia/testMRDS/dwi/regrid_dwi_MRDS_Diff_BIC_PDDs_CARTESIAN.nii.gz';
f_nComp       = '/datos/syphon/displasia/testMRDS/dwi/regrid_dwi_MRDS_Diff_BIC_NUM_COMP.nii.gz';
ff_values_in  = {'/datos/syphon/displasia/testMRDS/dwi/regrid_dwi_MRDS_Diff_BIC_FA.nii.gz'};
f_prefix      =  '/tmp/tests_MRDS';



VALUES = displasia_tckfixelsample(f_tck, f_PDD, f_nComp, ff_values_in, f_prefix);
