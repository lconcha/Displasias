function M = displasia_oli_load_txts(d,metric,doPlot)

% d = '/misc/sherrington2/Olimpia/proyecto/qti+/metrics/'
if nargin < 2
    doPlot = false;
end

%d = '/misc/sherrington2/Olimpia/proyecto/qti+/metrics/'
%metric = 'uFA'


ff_ctrl_l = dir(fullfile(d,metric,'ctrl*_l_dtd_covariance*.txt'));
ff_bcnu_l = dir(fullfile(d,metric,'bcnu*_l_dtd_covariance*.txt'));
ff_ctrl_r = dir(fullfile(d,metric,'ctrl*_r_dtd_covariance*.txt'));
ff_bcnu_r = dir(fullfile(d,metric,'bcnu*_r_dtd_covariance*.txt'));


n_ctrl_l = length(ff_ctrl_l);
n_bcnu_l = length(ff_bcnu_l);
n_ctrl_r = length(ff_ctrl_r);
n_bcnu_r = length(ff_bcnu_r);

if n_ctrl_l == n_ctrl_r
  Mctrl = zeros(50,10,n_ctrl_l);
else
  fprintf(1,'ERROR: Size mismatch for controls');
end
if n_bcnu_l == n_bcnu_r
  Mbcnu = zeros(50,10,n_ctrl_l);
else
  fprintf(1,'ERROR: Size mismatch for bcnu');
end

Mctrl = zeros(50,10,2,n_ctrl_l);
for i = 1 : n_ctrl_l
  fprintf(1,'Control %d\n',i);
  fl = fullfile(ff_ctrl_l(i).folder,ff_ctrl_l(i).name);  
  fr = strrep(fl,'vn_l_dtd','vn_r_dtd');
  fprintf(1,'  Left: %s\n  Right: %s\n',fl,fr)
  this_l = readmatrix(fl);
  this_r = readmatrix(fr);
  Mctrl(:,:,1,i) = readmatrix(fl); % left then right
  Mctrl(:,:,2,i) = readmatrix(fr);
end

Mbcnu = zeros(50,10,2,n_bcnu_l);
for i = 1 : n_bcnu_l
  fprintf(1,'BCNU %d\n',i);
  fl = fullfile(ff_bcnu_l(i).folder,ff_bcnu_l(i).name);  
  fr = strrep(fl,'vn_l_dtd','vn_r_dtd');
  fprintf(1,'  Left: %s\n  Right: %s\n',fl,fr)
  this_l = readmatrix(fl);
  this_r = readmatrix(fr);
  Mbcnu(:,:,1,i) = readmatrix(fl);  % left then right
  Mbcnu(:,:,2,i) = readmatrix(fr);
end

M.ctrl = Mctrl;
M.bcnu = Mbcnu;
M.hemis = {'l','r'};   % left then right

if doPlot
    mean_ctrl_l = nanmean(Mctrl(:,:,1,:),4);
    mean_ctrl_r = nanmean(Mctrl(:,:,2,:),4);
    
    mean_bcnu_l = nanmean(Mbcnu(:,:,1,:),4);
    mean_bcnu_r = nanmean(Mbcnu(:,:,2,:),4);
    
    all_means = [mean_ctrl_l mean_ctrl_r; mean_bcnu_l mean_bcnu_r];
    
    clim = [min(all_means(:)) max(all_means(:))];
    subplot(3,2,1); imagesc(mean_ctrl_l'); title(['1. Mean ctrl left. ' metric]); set(gca,'CLim',clim); colorbar
    subplot(3,2,2); imagesc(mean_ctrl_r'); title(['2. Mean ctrl right. ' metric]); set(gca,'CLim',clim); colorbar
    subplot(3,2,3); imagesc(mean_bcnu_l'); title(['3. Mean bcnu left. ' metric]); set(gca,'CLim',clim); colorbar
    subplot(3,2,4); imagesc(mean_bcnu_r'); title(['4. Mean bcnu right. ' metric]); set(gca,'CLim',clim); colorbar
    
    subplot(3,2,5); imagesc(mean_ctrl_r' - mean_bcnu_r'); title(['5. Delta right. ' metric]); colorbar
    subplot(3,2,6); imagesc(mean_ctrl_l' - mean_bcnu_l'); title(['6. Delta right. ' metric]); colorbar

end
