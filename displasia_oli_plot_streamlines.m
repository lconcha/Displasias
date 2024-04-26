function h = displasia_oli_plot_streamlines(f_tck,RESULTS,metric,comparison,msize,clim,pclus_threshold,puncorr_threshold)


mygray              = [0.5 0.5 0.5];
mylightgray         = [0.8 0.8 0.8];





%f_tck = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
%f_tck = '/datos/syphon/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';

tck = read_mrtrix_tracks(f_tck);



% prepare colormaps
cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
cmap_warm = uint8(cbrewer('seq','YlOrBr',128,'spline') .* 255); cmap_warm = flip(cmap_warm,1);
cmap_cool = uint8(cbrewer('seq','PuBuGn',128,'spline') .* 255); cmap_cool = flip(cmap_cool,1);
cmap_pval = hot(128); cmap_pval = flip(cmap_pval,1);



for s = 1 : length(tck.data)
  tmp_comparison        = ['p' comparison];
  
  thisline              = tck.data{s};
  thiscohen             = RESULTS.clusterstats.(metric).dcohen(s,:);
  thispcluster          = RESULTS.clusterstats.(metric).cluster_pvals_2D.(comparison)(s,:) < pclus_threshold;
  this_xyz_sig              = thisline;
    this_xyz_sig(~thispcluster,:)       = nan;
  this_xyz_sig_cohen        = thiscohen;
  this_xyz_sig_cohen(~thispcluster)   = nan;
  thispuncorr           = RESULTS.clusterstats.(metric).(tmp_comparison)(s,:);
  this_xyz_puncorr_sig  = thisline;
    this_xyz_puncorr_sig(thispuncorr > puncorr_threshold,:) = nan;
  h_lines(s)            = plot(thisline(:,1),thisline(:,2), 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
  %this_marker_size      = (1-thispuncorr) .* msize;
  this_marker_size      = abs(thiscohen) .* msize;
  h_scatterfilled(s)    = scatter(thisline(:,1),thisline(:,2),this_marker_size,thiscohen,'filled');
  h_scatterpuncorr(s)   = scatter(this_xyz_puncorr_sig(:,1),this_xyz_puncorr_sig(:,2),...
                          this_marker_size .* 1.5,mylightgray, 'LineWidth',1.0);
  h_scatterpcluster(s)  = scatter(this_xyz_sig(:,1),this_xyz_sig(:,2),...
                          this_marker_size .* 1.5,'w', 'LineWidth',2.0);
  set(gca,'colormap',cmap_div)
  hold on
end

view(180,270)
grid off; axis off; axis equal

if isempty(clim)
    lims = get(gca,'Clim');
    newlims = [abs(max(lims))*-1 max(lims)];
    set(gca,'Clim',newlims);
else
    set(gca,'Clim',clim);
end 


h_colorbar = colorbar(gca,'Color','w');
h_colorbar.Label.String = 'd-Cohen';

switch comparison
    case 'AgtB'
        comparison_txt = 'A > B';
    case 'AltB'
        comparison_txt = 'A < B';
    case 'AdiffB'
        comparison_txt = 'A\neqB';
    otherwise
        comparison_txt = comparison;
end

%if comparison == 'AgtB'; comparison_txt = 'Ctrl > BCNU';end
title([metric ' | ' comparison_txt])


lims = get(gca,'Clim');

set(gcf,'Color','k');
for s = 1 : 8
  subplot(3,3,s)
  ah = get(gca);
  ah.XLabel.Color = 'w';
  ah.YLabel.Color = 'w';
  ah.Title.Color  = 'w';
  ah.YColor = 'w';
  ah.XColor = 'w';
  set(gca,'XColor','w');
  set(gca,'YColor','w');
end


h = gca;

% scatter(0.2, 0.2,   msize,mygray,'filled');
% text   (0,   0.25,  ['|d-Cohen| = ' num2str(max(abs(lims)))], 'Color', mygray);
% scatter(0.2, 0,     msize.*0.5,mygray,'filled');
% text   (0,   0,     ['|d-Cohen| = ' num2str(0.5*max(abs(lims)))], 'Color', mygray);
% scatter(0.2, -0.2,  msize.*.05,mygray,'filled');
% text   (0,   -0.2,  ['|d-Cohen| = ' num2str(0.05*max(abs(lims)))], 'Color', mygray);
% scatter(0.2, -0.4,  msize,mygray, 'LineWidth',1);
% text   (0,   -0.4,  ['p_{uncorr} threshold = ' num2str(puncorr_threshold)], 'Color', mygray);
% scatter(0.2, -0.6,  msize,'w','LineWidth',2);
% text   (0,   -0.6,  ['p_{cluster} threshold = ' num2str(pclus_threshold)], 'Color', mygray);


