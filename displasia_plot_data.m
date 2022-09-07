
% prepare colormaps
cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
cmap_warm = uint8(cbrewer('seq','YlOrBr',128,'spline') .* 255); cmap_warm = flip(cmap_warm,1);
cmap_cool = uint8(cbrewer('seq','PuBuGn',128,'spline') .* 255); cmap_cool = flip(cmap_cool,1);
cmap_pval = hot(128); cmap_pval = flip(cmap_pval,1);
fig_all  = figure('units','normalized','outerposition',[0 0 1 1]);
fig_ctrl = figure('units','normalized','outerposition',[0 0 1 1]);
fig_bcnu = figure('units','normalized','outerposition',[0 0 1 1]);
fig_diff = figure('units','normalized','outerposition',[0 0 1 1]);

for m = 1 : nMetrics
  figure(fig_all)
    thisdata = mean(DATA(:,:,:,m),3);
    thistitle = metrics_table.shortName(m);
    thisrange = [metrics_table.rangemin(m) metrics_table.rangemax(m)];
    subplot(n1,n2,m)
    h(m) = imagesc(thisdata');
    title([thistitle '(all)'])
    set(gca,'Clim',thisrange);
    colormap(cmap_warm);colorbar
    lims(m,:) = get(gca,'Clim');

  figure(fig_ctrl)
    thisdata = mean(DATA(:,:,rat_table.group == "Control",m),3);
    thistitle = metrics_table.shortName(m);
    thisrange = [metrics_table.rangemin(m) metrics_table.rangemax(m)];
    subplot(n1,n2,m)
    h(m) = imagesc(thisdata');
    title([thistitle '(Control)'])
    set(gca,'Clim',thisrange);
    colormap(cmap_warm);colorbar
    lims(m,:) = get(gca,'Clim');

  figure(fig_bcnu)
    thisdata = mean(DATA(:,:,rat_table.group == "BCNU",m),3);
    thistitle = metrics_table.shortName(m);
    thisrange = [metrics_table.rangemin(m) metrics_table.rangemax(m)];
    subplot(n1,n2,m)
    h(m) = imagesc(thisdata');
    title([thistitle '(BCNU)'])
    set(gca,'Clim',thisrange);
    colormap(cmap_warm);colorbar
    lims(m,:) = get(gca,'Clim');

  figure(fig_diff)
    thisdata = mean(DATA(:,:,rat_table.group == "Control",m),3) - ...
               mean(DATA(:,:,rat_table.group == "BCNU"   ,m),3);
    thistitle = metrics_table.shortName(m);
    thisrange = [metrics_table.rangemin(m) metrics_table.rangemax(m)];
    subplot(n1,n2,m)
    h(m) = imagesc(thisdata');
    title([thistitle '(Ctrl-BCNU)'])
    colormap(cmap_div);colorbar
    lims(m,:) = get(gca,'Clim');
    newlims = [abs(max(lims(m,:)))*-1 max(lims(m,:))];
    set(gca,'Clim',newlims);
    lims(m,:) = newlims;

end

saveas(fig_all, 'results/metrics_all.svg');
saveas(fig_ctrl,'results/metrics_ctrl.svg');
saveas(fig_bcnu,'results/metrics_bcnu.svg');
saveas(fig_diff,'results/metrics_diff.svg');

