function [tck,tck_world] = displasia_load_tck_voxelcoords(f_tck,f_image)


fprintf             ('Reading strides from %s\n',f_image);
systemcommand       = ['export LD_LIBRARY_PATH="";mrinfo -strides ' f_image];
[~,result]               = system(systemcommand);
orig_strides        = str2num(result);

if length(orig_strides) ~= 3
    error('Image provided should have three dimensions');
    return
end

% here we make sure that we have strides like '1,2,3,4' (positive and
% monotonically ascending)
f_tmpImage          = [tempname '.nii'];
forced_strides      = [1 2 3];
forced_strides_str  = sprintf('%d,%d,%d',forced_strides);
systemcommand       = ['export LD_LIBRARY_PATH="";mrconvert -strides ' forced_strides_str ' ' f_image ' ' f_tmpImage];
[~,~]               = system(systemcommand);
f_image             = f_tmpImage;


tck_world           = read_mrtrix_tracks(f_tck);
f_tmptck            =  [tempname '.tck'];
systemcommand       = ['export LD_LIBRARY_PATH="";tckconvert -scanner2voxel ' f_image ' ' f_tck ' ' f_tmptck ' -force -quiet'];
[~,~]               = system(systemcommand);
tck                 = read_mrtrix_tracks(f_tmptck);


[~,~]               = system(['rm -f ' f_tmpImage]);
[~,~]               = system(['rm -f ' f_tmptck]);



