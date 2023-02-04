function VALUES = displasia_tckfixelsample(f_tck, f_PDD, f_nComp, ff_values_in, f_prefix)
% VALUES = displasia_tckfixelsample(f_tck, f_PDD, f_nComp, ff_values_in, f_prefix)
%
% f_tck         : Filename for the streamlines tck
% f_PDD         : Filename for the Principal Diffusion Directions file (MRDS, 4D).
% f_nComp       : Filename for the number of components (MRDS, 3D).
% ff_values_in  : Cell array of filenames of MRDS metrics to sample. 
%                 Each file should be MRDS, 4D.
% f_prefix      : Prefix for the output file names.
%
% Consider:
% addpath('/home/lconcha/software/mrtrix_matlab/matlab');
% addpath(genpath('/home/lconcha/software/dicm2nii-master'))
% addpath /home/lconcha/software/Displasias/
%
% __________________________________________________________________________________
% EXAMPLE:
% f_tck         = 'dwi/15/tck/dwi_l_out_resampled_native.tck';
% f_PDD         = 'dwi/dwi_MRDS_Diff_BIC_PDDs_CARTESIAN.nii.gz';
% f_MRDS_ncomp  = 'dwi/dwi_MRDS_Diff_BIC_NUM_COMP.nii.gz';
% f_MRDS_FA     = 'dwi/dwi_MRDS_Diff_BIC_FA.nii.gz';
% f_MRDS_MD     = 'dwi/dwi_MRDS_Diff_BIC_MD.nii.gz';
% ff_values     = {f_MRDS_FA, f_MRDS_MD};
% f_prefix      = '/tmp/prefix';
% 
% VALUES = displasia_tckfixelsample(f_tck, f_PDD, f_MRDS_ncomp, ff_values, f_prefix);
% __________________________________________________________________________________
%
% LU15 (0N(H4
% INB-UNAM
% Feb 2023
% lconcha@unam.mx


fprintf('Loading %s\n',f_tck);
tck = read_mrtrix_tracks(f_tck);




%% Load voxel data

fprintf('Loading %s\n',f_PDD);
PDD    = niftiread(f_PDD);
info = niftiinfo(f_PDD);
if ndims(PDD) ~= 4
    fprintf(1,'ERROR. %s does not have 4 dimensions. It should be a 4D volume with nvolumes = 3, 6, 9 or 12. Bye.\n',f_PDD);
    VALUES = [];
    return
end

fprintf('Loading %s\n',f_nComp);
nComp    = niftiread(f_nComp);
info = niftiinfo(f_nComp);
if ndims(nComp) ~= 3
    fprintf(1,'ERROR. %s should have three dimensions Bye.\n',f_nComp);
    VALUES = [];
    return
end



%% displasia-specific problem related to brkraw. Need to permute axes.
if size(PDD,2) > size(PDD,3)
  fprintf(1,'Woah, it seems like slices in the PDD file are in the third dimension. For displasia project they should be on the second dimension.\n');
  fprintf(1,'  ... will convert the file to have correct strides for you outside of matlab.\n')
  tmpPDD = '/tmp/PDD.nii.gz';
  systemcommand = ['mrconvert -strides 1,2,3,4 -quiet ' f_PDD ' ' tmpPDD];
  fprintf(1,'  executing: %s\n',systemcommand);
  [status,result] = system(systemcommand);
  fprintf('Loading %s\n',tmpPDD);
  PDD = niftiread(tmpPDD);
  infoPDD = niftiinfo(tmpPDD);
  [status,result] = system(['rm -f ' tmpPDD]);
end
if size(nComp,2) > size(nComp,3)
  fprintf(1,'Woah, it seems like slices in the nComp file are in the third dimension. For displasia project they should be on the second dimension.\n');
  fprintf(1,'  ... will convert the file to have correct strides for you outside of matlab.\n')
  tmpnComp = '/tmp/nComp.nii.gz';
  systemcommand = ['mrconvert -strides 1,2,3 -quiet ' f_nComp ' ' tmpnComp];
  fprintf(1,'  executing: %s\n',systemcommand);
  [status,result] = system(systemcommand);
  fprintf('Loading %s\n',tmpnComp);
  nComp = niftiread(tmpnComp);
  infonComp = niftiinfo(tmpnComp);
  [status,result] = system(['rm -f ' tmpnComp]);
end


%% Prepare tsfs
%nFixels = size(PDD,4) ./ 3;
nFixels = 3; % forcing 3 pixels

tsf_par  = tck;
tsf_perp = tck;
tsf_index_par = tck;
tsf_ncomp     = tck;


%% Identify parallel/perpendicular
fprintf(1,'Identifying par/perp... ')
for s = 1 : length(tck.data)
   fprintf (1,'%d ',s);
   this_streamline      = tck.data{s};
   this_index_par       = zeros(size(this_streamline,1),1);
   this_index_perp      = zeros(size(this_streamline,1),1);
   this_nComp           = zeros(size(this_streamline,1),1);
   for p = 1 : size(this_streamline,1);
       Axyz = this_streamline(p,:);
       if p == size(this_streamline,1)
        Bxyz = this_streamline(p-1,:);
       else
        Bxyz = this_streamline(p+1,:);
       end
       
       normSegment = (Axyz-Bxyz) ./ norm(Axyz-Bxyz);
       vox_indices = [Axyz 1]  * inv(info.Transform.T);
       vox_indices = vox_indices(1:3);
       mindices    = vox_indices + 1;
       matlab_indices = uint8(vox_indices + 1);

       PDD1(1) =  interp3(PDD(:,:,:,1),mindices(2), mindices(1), mindices(3)); % I cannot get interpn to work, so I do this stupid thing.
       PDD1(2) =  interp3(PDD(:,:,:,2),mindices(2), mindices(1), mindices(3));
       PDD1(3) =  interp3(PDD(:,:,:,3),mindices(2), mindices(1), mindices(3));

       PDD2(1) =  interp3(PDD(:,:,:,4),mindices(2), mindices(1), mindices(3)); 
       PDD2(2) =  interp3(PDD(:,:,:,5),mindices(2), mindices(1), mindices(3));
       PDD2(3) =  interp3(PDD(:,:,:,6),mindices(2), mindices(1), mindices(3));

       PDD3(1) =  interp3(PDD(:,:,:,7),mindices(2), mindices(1), mindices(3)); 
       PDD3(2) =  interp3(PDD(:,:,:,8),mindices(2), mindices(1), mindices(3));
       PDD3(3) =  interp3(PDD(:,:,:,9),mindices(2), mindices(1), mindices(3));

       dots(1) = dot(normSegment,PDD1./norm(PDD1));
       dots(2) = dot(normSegment,PDD2./norm(PDD2));
       dots(3) = dot(normSegment,PDD3./norm(PDD3));

       thisnComp = interp3(nComp,mindices(2), mindices(1), mindices(3), 'nearest');

       if thisnComp < 3
         dots(thisnComp+1:end) = NaN; % Remove PDDs if nCom does not support them.
       end

       if thisnComp > 1
           [themax,indexpar]  = max(abs(dots));       
           [themin,indexperp] = min(abs(dots));
       else
           [themax,indexpar]  = max(abs(dots));       
           themin             = NaN;
           indexperp          = 3;
       end



       thisnComp = interp3(nComp,mindices(2), mindices(1), mindices(3), 'nearest');



       this_index_par(p,1)  = indexpar;
       this_index_perp(p,1) = indexperp;
       this_nComp(p,1)      = thisnComp;
   end
   try
    tsf_index_par.data{s}  = this_index_par;
    tsf_index_perp.data{s} = this_index_perp;
    tsf_ncomp.data{s}      = this_nComp;
   catch
    fprintf(1,'Hey!')
   end
end
fprintf (1,'\nFinished identifying par/perp\n',s);


%% Do the sampling
for i = 1 : length(ff_values_in)
    f_values_in = ff_values_in{i};
    fprintf('Loading %s\n',f_values_in);
    V    = niftiread(f_values_in);
    info      = niftiinfo(f_values_in);
    [fold,fname,ext] = fileparts(info.Filename);
    varName = strrep(fname,'.nii','');
    if ndims(V) ~= 4
        fprintf(1,'ERROR. %s does not have 4 dimensions. This script can only handle 4D. Bye.\n',f_values_in);
        VALUES = [];
        return
    end
    if size(V,2) > size(V,3)
      fprintf(1,'Woah, it seems like slices in the volume to sample from are in the third dimension. For displasia project they should be on the second dimension.\n');
      fprintf(1,'  ... will convert the file to have correct strides for you outside of matlab.\n')
      tmpvaluesfile = '/tmp/tmpvaluesfile.nii.gz';
      systemcommand = ['mrconvert -strides 1,2,3,4 -quiet ' f_values_in ' ' tmpvaluesfile];
      fprintf(1,'  executing: %s\n',systemcommand);
      [status,result] = system(systemcommand);
      fprintf('Loading %s\n',tmpvaluesfile);
      V = niftiread(tmpvaluesfile);
      info = niftiinfo(tmpvaluesfile);
      [status,result] = system(['rm -f ' tmpvaluesfile]);
    end
    
    for s = 1 : length(tck.data)
       %fprintf (1,'%d ',s);
       this_streamline = tck.data{s};
       this_data_par        = zeros(size(this_streamline,1),1);
       this_data_perp       = zeros(size(this_streamline,1),1);
       for p = 1 : size(this_streamline,1);
           xyz = this_streamline(p,:);
           
           vox_indices = [xyz 1]  * inv(info.Transform.T);
           vox_indices = vox_indices(1:3);
           mindices    = vox_indices + 1;
           matlab_indices = uint8(vox_indices + 1);
    
         
           %thisnComp = interp3(nComp,mindices(2), mindices(1), mindices(3), 'nearest');
           thisnComp  = tsf_ncomp.data{s}(p);
           indexpar   = tsf_index_par.data{s}(p);
           indexperp  = tsf_index_perp.data{s}(p);
    
           
           vals(1) = interp3(V(:,:,:,1),mindices(2), mindices(1), mindices(3));
           vals(2) = interp3(V(:,:,:,2),mindices(2), mindices(1), mindices(3));
           vals(3) = interp3(V(:,:,:,3),mindices(2), mindices(1), mindices(3));
    
           if thisnComp < 3
            vals(thisnComp+1:end) = -1; % remove values if nComp does not support them.
           end
    
           if max(vals) < 0
            fprintf(1,'WTF? All values are invalid!')
            fprintf(1,'Streamline %d, point %d\n',s,p);
            vals
           end
    
           val_par  = vals(indexpar);
           val_perp = vals(indexperp);
    
           this_data_par(p,1)  = val_par;
           this_data_perp(p,1) = val_perp;       
       end
       tsf_par.data{s}  = this_data_par;
       tsf_perp.data{s} = this_data_perp;
       try
        tsf_index_par.data{s} = this_index_par;
       catch
        fprintf(1,'Hey!')
       end
    end
    fprintf (1,'\nFinished sampling %s\n',fname);
    
    
    f_tsf_par_out  = [f_prefix '_' varName '_par.tsf'];
    f_tsf_perp_out = [f_prefix '_' varName '_perp.tsf'];
    fprintf(1,'  [INFO] Writing tsf_par: %s\n',f_tsf_par_out);
    write_mrtrix_tsf(tsf_par,f_tsf_par_out)
    fprintf(1,'  [INFO] Writing tsf_perp: %s\n',f_tsf_perp_out);
    write_mrtrix_tsf(tsf_perp,f_tsf_perp_out)

    VALUES.par.(varName)  = tsf_par.data;
    VALUES.perp.(varName) = tsf_perp.data;
end

f_tsf_par_index_out = [f_prefix '_par_index.tsf'];
fprintf(1,'  [INFO] Writing tsf_index_par: %s\n',f_tsf_par_index_out);
write_mrtrix_tsf(tsf_index_par,f_tsf_par_index_out)
