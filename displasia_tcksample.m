function VALUES = displasia_tcksample(f_tck,f_values_in,f_txt_out,f_tsf_out)
% VALUES = displasia_tcksample(tck,f_values_in,f_txt_out)

% addpath('/home/lconcha/software/mrtrix_matlab/matlab');
% addpath(genpath('/home/lconcha/software/dicm2nii-master'))
% addpath /home/lconcha/software/Displasias/

%%%%%% bash
%mrgrid -template roi_26_15_47.nii dwi_MRDS_Diff_BIC_NUM_COMP.nii.gz regrid regrid.nii -strides roi_26_15_47.nii -force
%%%%%%%
%f_MRDS_ncomp = 'dwi/roi_26_15_47.nii';


fprintf('Loading %s\n',f_tck);
tck = read_mrtrix_tracks(f_tck);



fprintf('Loading %s\n',f_values_in);
V    = niftiread(f_values_in);
info = niftiinfo(f_values_in);

if ndims(V) > 3
    fprintf(1,'ERROR. %s has 4 dimensions. This script can only handle 3D. Bye.\n',f_values_in);
    VALUES = [];
    
end

%% displasia-specific problem related to brkraw. Need to permute axes.
if size(V,2) > size(V,3)
  fprintf(1,'Woah, it seems like slices are in the third dimension. For displasia project they should be on the second dimension.\n');
  fprintf(1,'  ... will convert the file to have correct strides for you outside of matlab.\n')
  tmpvaluesfile = '/tmp/tmpvaluesfile.nii.gz';
  systemcommand = ['mrconvert -strides 1,2,3 ' f_values_in ' ' tmpvaluesfile];
  fprintf(1,'  executing: %s\n',systemcommand);
  [status,result] = system(systemcommand);
  fprintf('Loading %s\n',tmpvaluesfile);
  V = niftiread(tmpvaluesfile);
  info = niftiinfo(tmpvaluesfile);
  [status,result] = system(['rm -f ' tmpvaluesfile]);
end


tsf = tck;

fid = fopen(f_txt_out,'w');

for s = 1 : length(tck.data)
   this_streamline = tck.data{s};
   this_data       = zeros(size(this_streamline,1),1);
   for p = 1 : size(this_streamline,1);
       xyz = this_streamline(p,:);
       vox_indices = [xyz 1]  * inv(info.Transform.T);
       vox_indices = vox_indices(1:3);
       matlab_indices = uint8(vox_indices + 1);
       val = V(matlab_indices(1),matlab_indices(2),matlab_indices(3));
       %fprintf(1,'Streamline %d, point %d, xyz(%1.2f,%1.2f,%1.2f), ncomp : %d\n',s,p, xyz(1), xyz(2), xyz(3), val);
       fprintf(fid,'%1.3f ',val);
       this_data(p,1) = val;
   end
   fprintf(fid,'\n');
   tsf.data{s} = this_data;
end

fprintf(1,'Writing tsf: %s\n',f_tsf_out);
write_mrtrix_tsf(tsf,f_tsf_out)

fclose(fid);
VALUES = tsf.data;