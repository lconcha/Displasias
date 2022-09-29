function displasia_prevalence_maps(RESULTS,m)


f_tck = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
tck = read_mrtrix_tracks(f_tck);
cmap_prev = uint8(cbrewer('seq','Reds',128,'spline') .* 255); cmap_prev = flip(cmap_prev,1);
msize = 50;
mygray              = [0.5 0.5 0.5];
mylightgray         = [0.8 0.8 0.8];

idx_ctrl = RESULTS.data.idx_ctrl;
idx_bcnu = RESULTS.data.idx_bcnu;

fs = fieldnames(RESULTS.clusterstats);
metric = fs{m};

% fs = fieldnames(RESULTS.clusterstats);
% for f = 1:length(fs)
%   if regexp(fs{f},metric)
%       m = f;
%       fprintf(1,'%s is m=%d\n',metric,m);
%       break
%   end
% end



thisdata_ctrl = squeeze(RESULTS.data.DATA(:,:,idx_ctrl,m));
thisdata_bcnu = squeeze(RESULTS.data.DATA(:,:,idx_bcnu,m));

meanctrl = mean(thisdata_ctrl,3);
stdctrl  = std(thisdata_ctrl,1,3);


BCNU_z = zeros(size(thisdata_bcnu));
for s = 1 : size(thisdata_bcnu,3);
   thiss = squeeze(thisdata_bcnu(:,:,s));
   thisz = (thiss - meanctrl) ./ stdctrl;
   BCNU_z(:,:,s) = thisz;
end

preval = sum( abs(BCNU_z) >= 2 ,3) ./ sum(idx_bcnu); 




for s = 1 : length(tck.data)
  
  thisline              = tck.data{s};
  h_lines(s)            = plot(thisline(:,1),thisline(:,2), 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
  thisvalues            = preval(s,:);
  h_scatterfilled(s)    = scatter(thisline(:,1),thisline(:,2),msize,thisvalues,'filled');
  hold on
end



view(180,270)
grid off; axis off; axis equal
set(gcf,'Color','k');
colormap(cmap_prev);
hold off; colorbar
h_colorbar = colorbar(gca,'Color',[0.5 0.5 0.5]);
h_colorbar.Label.String = 'Prevalence of |z| >=2';
set(gca,"Clim",[0 0.4])
title(metric,'Color','w')