


[status,hname]= unix('hostname');
hname = deblank(hname);

switch hname
    case 'mansfield'
        addpath('/home/inb/lconcha/fmrilab_software/mrtrix3/matlab');
        figuresfolder = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/results/figures';
        addpath /home/inb/lconcha/fmrilab_software/tools/matlab/toolboxes/cbrewer/cbrewer
        addpath(genpath('/home/inb/lconcha/fmrilab_software/tools/matlab/toolboxes/matGeom/'));

%         mrds_basename = '/misc/nyquist/lconcha/displasia/CTRL/64A/30/derivatives/dwi/regrid_dwi_MRDS_Diff_BIC';
%         f_tck         = '/misc/nyquist/lconcha/displasia/CTRL/64A/30/derivatives/dwi/14/tck/dwi_l_out_resampled_native.tck';
        %f_tck         = '/misc/nyquist/lconcha/displasia/CTRL/64A/30/derivatives/dwi/14/tck/onestreamline.tck';

        mrds_basename = '/misc/nyquist/dcortes_aylin/displaciasCorticales/preproc/37A/ses-P30/dwi/MRDS/regrid_37A_mrds_MRDS_Diff_BIC';
        f_tck         = '/misc/nyquist/dcortes_aylin/displaciasCorticales/derivatives/37A/ses-P30/minc/tck/37A_l_14_out_resampled_10.tck';

        f_PDD         = [mrds_basename, '_PDDs_CARTESIAN.nii.gz'];
        f_nComp       = [mrds_basename, '_NUM_COMP.nii.gz'];
        ff_values_in  = {[mrds_basename, '_FA.nii.gz']};
        f_prefix      =  '/tmp/tests_MRDS';

    case 'syphon'
        addpath('/home/lconcha/software/mrtrix_matlab/matlab');
        addpath(genpath('/home/lconcha/software/dicm2nii-master'))
        addpath /home/lconcha/software/Displasias/
        f_tck         = '/datos/syphon/displasia/testMRDS/dwi/one.tck';
        f_PDD         = '/datos/syphon/displasia/testMRDS/dwi/regrid_dwi_MRDS_Diff_BIC_PDDs_CARTESIAN.nii.gz';
        f_nComp       = '/datos/syphon/displasia/testMRDS/dwi/regrid_dwi_MRDS_Diff_BIC_NUM_COMP.nii.gz';
        ff_values_in  = {'/datos/syphon/displasia/testMRDS/dwi/regrid_dwi_MRDS_Diff_BIC_FA.nii.gz'};
        f_prefix      =  '/tmp/tests_MRDS';


end



VALUES = displasia_tckfixelsample(f_tck, f_PDD, f_nComp, ff_values_in, f_prefix);
