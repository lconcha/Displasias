
resultsdir = '/misc/sherrington2/Olimpia/proyecto/qti+';
streamlinemasksdir = '/tmp/qti';

path_to_out_folder = '/tmp/qti';

niftimetadataFileName = '/misc/sherrington2/Olimpia/proyecto/preproc/R94/R94A/dwi__d_mask_correg_one.nii.gz';
nifti_metadata = niftiinfo(niftimetadataFileName);
nifti_metadata.Datatype = 'double';
nifti_metadata.BitsPerPixel = 64;

S = dir(fullfile(resultsdir, '**', 'invariants.mat'));
% Get full paths
files = fullfile({S.folder}, {S.name})';

allKshear = [];
allKmu    = [];
for r = 1 : length(files)
  thisfile = files{r};
  load(thisfile);
  %niftiwrite(invariants.K_mu,[path_to_out_folder filesep 'qtiplus_K_mu'],nifti_metadata,'Compressed',true);
  parts = strsplit(thisfile, '/');
  rat = parts{8};
  f_thismask = [streamlinemasksdir '/' rat '_map.nii'];
  try
    thismask = niftiread(f_thismask);
  catch
      continue
  end
  kmu = invariants.K_mu(thismask>0);
  kshear = invariants.K_shear(thismask>0);
  %figure
  %scatter(kmu,kshear); xlabel('kmu'); ylabel('kshear')
  %drawnow
  allKshear = [allKshear;kshear];
  allKmu    = [allKmu;kmu];
end
scatter(allKmu,allKshear,'filled','MarkerFaceAlpha',0.05); xlabel('kmu'); ylabel('kshear')
set(gca,"XLim",[0 2],"YLim",[0 2])