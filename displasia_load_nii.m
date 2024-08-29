function [info,im] = displasia_load_nii(f_image)

fprintf             ('Reading strides from %s\n',f_image);
systemcommand       = ['export LD_LIBRARY_PATH="";mrinfo -strides ' f_image];
[~,result]          = system(systemcommand);
orig_strides        = str2num(result);


% here we make sure that we have strides like '1,2,3,4' (positive and
% monotonically ascending)
f_tmpImage          = [tempname '.nii'];
forced_strides      = 1:1:length(orig_strides);
forced_strides_str  = regexprep(num2str(forced_strides),'\s+',',');
systemcommand       = ['export LD_LIBRARY_PATH="";mrconvert -strides ' forced_strides_str ' ' f_image ' ' f_tmpImage];
[~,~]               = system(systemcommand);
f_image             = f_tmpImage;

im                  = niftiread(f_image);
info                = niftiinfo(f_image);

[~,~]               = system(['rm -f ' f_tmpImage]);
  