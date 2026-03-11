function hf = displasia_oli_plot_just_cohen(pcluster,varname,heminame)


%cmap_div  = flipdim(uint8(cbrewer('div','PuOr',128, 'spline') .* 255),1);
% cmap_div  = 255-cmap_div;
%cmaploaded = load('conchamap');
cmaploaded = load('managua');
%cmaploaded = load('berlin');
%cmap_div  = flipdim(cmaploaded.managua,1);
%cmap_div = crameri('berlin');
myCell = struct2cell(cmaploaded); % myCell is a 1x1 cell array containing the 2x3 matrix
cmap_div = myCell{1};
cmap_div = flipdim(cmap_div,1);
mygray    = [0.7 0.7 0.7];
mydarkgray = [0.3 0.3 0.3];
clim = [-1.5 1.5];


% get coordinates and values
x = pcluster.(varname).(heminame).xyz(:,:,1);
y = pcluster.(varname).(heminame).xyz(:,:,2);
d = pcluster.(varname).(heminame).dcohen;
base_marker_size = 50;
%d_marker_size      = abs(d) .* base_marker_size;

d_marker_size = base_marker_size;






% plot the clusters
sig_clusters = find(pcluster.(varname).(heminame).cluster_pvals.AdiffB < pcluster.(varname).(heminame).clusterpthreshold);
for c = 1 : length(sig_clusters)
  fprintf(1,'Plotting cluster %d\n',c);
  xx = x(pcluster.(varname).(heminame).clusterlabels.AdiffB == sig_clusters(c));
  yy = y(pcluster.(varname).(heminame).clusterlabels.AdiffB == sig_clusters(c));
  k = boundary(xx, yy, 0.8); 
  boundary_x = xx(k);
  boundary_y = yy(k);
  %h.clusters(c) = plot(boundary_x,boundary_y,' -w', 'LineWidth', 2);
  h.clusters(c)  = fill(boundary_x,boundary_y,'w');
  hold on;
  % Plot the boundary p values
  %h_pb = scatter(boundary_x,boundary_y,base_marker_size,'MarkerEdgeColor','w','LineWidth',3);

end
hold on;

% plot the streamlines
h_streamlines = plot(pcluster.(varname).(heminame).xyz(:,:,1)',pcluster.(varname).(heminame).xyz(:,:,2)',...
    'Color',mygray,'LineWidth',1);


% Plot Cohen's d
h_d = scatter(x(:),y(:),d_marker_size(:),-d(:),'filled'); % I put a -d here because of how I calculated d. I want -d for when bcnu<ctrl.
set(gca,'Clim',clim)
set(gca,'colormap',cmap_div)
h_colorbar = colorbar;
h_colorbar.Color = 'w';
h_colorbar.Limits = clim;
h_colorbar.Ticks = [clim(1) 0 clim(2)];
hold on;

% Plot uncorrected p
puncorr = pcluster.(varname).(heminame).pAdiffB;
idx = find(puncorr < pcluster.(varname).(heminame).clusterformingpthreshold);
%h_p = scatter(x(idx),y(idx),d_marker_size(idx),puncorr(idx),'MarkerEdgeColor',mygray,'LineWidth',1);



% finish up with colors and views.
hold off
set(gcf,'Color','k');
ah = get(gca);
ah.XLabel.Color = 'w';
ah.YLabel.Color = 'w';
ah.Title.Color  = 'w';
ah.YColor = 'w';
ah.XColor = 'w';
set(gca,'XColor','w');
set(gca,'YColor','w');
set(gca,'Color','k')
axis off
if strmatch(heminame,'l')
  set(gca, 'XDir', 'reverse');
else
  fprintf(1,'.\n');
end
thistitle = sprintf('%s, side: %s | pvertex: %1.2f, pcluster: %1.2f',...
    varname,...
    heminame,...
    pcluster.(varname).(heminame).clusterformingpthreshold,...
    pcluster.(varname).(heminame).clusterpthreshold)
title(thistitle);

hf = gcf;
