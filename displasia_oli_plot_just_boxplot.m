function hf = displasia_oli_plot_just_boxplot(pcluster,varname,varnames,hemi,hemis,fullM,groupidx,dirfigs)


doSave = true;
if isempty(dirfigs)
  doSave = false;
end

d = pcluster.(varname).(hemi).dcohen;
varidx = strmatch(varname,varnames);
hemiidx = strmatch(hemi,hemis);


sig_clusters = find(pcluster.(varname).(hemi).cluster_pvals.AdiffB < pcluster.(varname).(hemi).clusterpthreshold);
nclusters = length(sig_clusters);
fprintf(1,'There are %d significant clusters\n',nclusters)
col = 1;
for c = 1 : nclusters
 
  idx_cluster = pcluster.(varname).(hemi).clusterlabels.AdiffB == sig_clusters(c);
  dz          = d;
  dz(~idx_cluster) = 0;
  [val,idx] = max(abs(dz(:)));
  [sline,depth]     = ind2sub(size(d),idx);
  fprintf(1,'%s in %s hemisphere. Cluster %d: Maximum d=%1.3g at streamline %d, vertex %d\n',varname,hemi,c,val,sline,depth);

  subplot(1,nclusters+1,1);
  % plot the streamlines
  x = pcluster.(varname).(hemi).xyz(:,:,1)';
  y = pcluster.(varname).(hemi).xyz(:,:,2)';
  h_streamlines = plot(x,y,'LineWidth',1,'Color',[0.6 0.6 0.6]); hold on;
  h_idx         = text(x(depth,sline)+0.5,y(depth,sline),num2str(c),'Color','r','FontSize',14);
  h_point       = scatter(x(depth,sline),y(depth,sline),'MarkerFaceColor','r');
  if strmatch(hemi,'l')
    set(gca, 'XDir', 'reverse');
  end
  axis off
  
  col = col+1;
  subplot(1,nclusters+1,col);
  % plot the boxplots
  values = squeeze(fullM(sline,depth,hemiidx,varidx,:));
  hbx = boxplot(values,groupidx,'labels',{'ctrl','bcnu'},'Color','w','Width',0.1);
  thistitle = sprintf('%s %s - Cluster %d, d=%1.3g; streamline %d, vertex %d\n',varname,hemi,c,val,sline,depth);
  title(thistitle)
  set(hbx(:),'Color','w','LineStyle','-')
  set(hbx(7,:),'Visible','off')
  set(hbx(:,:),'LineWidth',2)
  set(hbx(3:4,:),'Visible','off')
end
subplot(1,nclusters+1,1); hold off;



% finish up with colors and views.
hold off
set(gcf,'Color','k');
subplot(1,nclusters+1,1);
ah = get(gca);
ah.XLabel.Color = 'w';
ah.YLabel.Color = 'w';
ah.Title.Color  = 'w';
ah.YColor = 'w';
ah.XColor = 'w';
ah.Color = 'k';
col=1;
for c = 1 : nclusters
    col = col+1;
    subplot(1,nclusters+1,col);
    hold off
    set(gcf,'Color','k');
    set(gca,'Color','k')
    set(gca,'YColor','w','XColor','w')
    ah = gca;
    ah.Title.Color  = 'w';
    ah.Title.FontSize = 16
    ah.YTick = ah.YLim;
    ah.Box = false;
    ah.TickDir = 'out';
    y_tick_values = ah.YTick;
    formatted_labels = cellstr(sprintf('%.2f\n', y_tick_values)); 
    ah.YTickLabel = formatted_labels;
    ah.FontSize = 20;
end





hf = gca;

if doSave
  f_svg = fullfile(dirfigs,'svg',[varname '_' hemi '_boxplots.svg'])
  f_png = fullfile(dirfigs,'png',[varname '_' hemi '_boxplots.png'])
   set(gcf, 'InvertHardcopy', 'off');
  saveas(gcf, f_svg);
  saveas(gcf, f_png);
else
  fprintf(1,'Not saving files\n');
end



