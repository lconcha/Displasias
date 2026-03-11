function h = tttmmmppp(pcluster,varname)


cmap_div  = flipdim(uint8(cbrewer('div','PuOr',128, 'spline') .* 255),1);
mygray    = [0.7 0.7 0.7];


x = pcluster.(varname).xyz(:,:,1);
y = pcluster.(varname).xyz(:,:,2);
d = pcluster.(varname).dcohen;
base_marker_size = 50;
d_marker_size      = abs(d) .* base_marker_size;


% Plot Cohen's d
h_d = scatter(x(:),y(:),d_marker_size(:),-d(:),'filled'); % I put a -d here because of how I calculated d. I want -d for when bcnu<ctrl.
set(gca,'Clim',[-1 1])
set(gca,'colormap',cmap_div)
h_colorbar = colorbar;
h_colorbar.Color = 'w';
h_colorbar.Limits = [-1 1];
h_colorbar.Ticks = [-1 0 1];
hold on;

% Plot uncorrected p
puncorr = pcluster.(varname).pAdiffB;
idx = find(puncorr < pcluster.(varname).clusterformingpthreshold);
h_p = scatter(x(idx),y(idx),d_marker_size(idx),puncorr(idx),'MarkerEdgeColor',mygray);

sig_clusters = find(pcluster.(varname).cluster_pvals.AdiffB < pcluster.(varname).clusterpthreshold);
for c = 1 : length(sig_clusters)
  fprintf(1,'Plotting cluster %d\n',c);
  xx = x(pcluster.(varname).clusterlabels.AdiffB == sig_clusters(c));
  yy = y(pcluster.(varname).clusterlabels.AdiffB == sig_clusters(c));
  k = boundary(xx, yy, 0.8); 
  h.clusters(c) = plot(xx(k),yy(k),' -w','LineWidth',2);
end

hold off

%h.plots = plot(pcluster.FA.xyz(:,:,1),pcluster.FA.xyz(:,:,2),' .r');


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
  