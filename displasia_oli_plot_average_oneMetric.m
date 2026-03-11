function h = displasia_oli_plot_average_oneMetric(fullM,vars,varn,hemis,groupidx,dirfigs)

%fullM is [nstreamlines,ndepths,nhemis,nmetrics,nrats ];


doSavePlot = true;
if nargin < 6
    doSavePlot = false;
end

%f_tck =  '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
f_tck = './example_files/streamlines_50_10.tck';

function local_histogram(vctrl,vbcnu,xlim,hemi)
  dNPoints = 100;
  colorctrl = [0.4 0.4 0.4];
  colorbcnu = [47/255 79/255 79/255];
  facealpha = 0.5;
  [dctrl, xc] = ksdensity(vctrl,'NumPoints',dNPoints);
  [dbcnu, xb] = ksdensity(vbcnu,'NumPoints',dNPoints);
  area(xc, dctrl, 'FaceColor', colorctrl, 'FaceAlpha', facealpha, 'EdgeColor', colorctrl, 'LineWidth', 1.5);
  hold on
  area(xb, dbcnu, 'FaceColor', colorbcnu, 'FaceAlpha', facealpha, 'EdgeColor', colorbcnu, 'LineWidth', 1.5);
  set(gca,'Color','k','XColor','w','YColor','w','box','off');
  set(gca,'XLim',xlim);
  set(gca,'XTick',xlim);
  yticks([]);
  ax = gca;
  ax.YAxis.Visible = 'off';
  box off;
  set(gcf, 'Color', 'k');
  title([var '. Hemisphere: ' hemi],'Color','w');
  legend({'ctrl' ,'bcnu'},'interpreter','none','Location','southoutside','TextColor','w')
  set(gca,'TickDir','out')
end



cmap = parula(128);
%s_cmap = 'batlowW';
%cmap = load(['/misc/lauterbur2/lconcha/code/ScientificColourmaps/' s_cmap '/' s_cmap '.mat']);
%cmap = cmap.(s_cmap);
%cmap = flipdim(cbrewer('seq','YlGnBu',100),1);
%cmap = flipdim(cbrewer('seq','PuBuGn',200,'linear'),1);
clim = vars{varn,2};
var  = vars{varn,1};




%fh = figure('Position',[600 500 1600 650]);
subplot(321);
thetitle = ['1 ' var ' ' hemis{1} ' ctrl'];
datatoshow = squeeze(nanmean(fullM(:,:,1,varn,groupidx==1),5));
h = displasia_show_streamlines_with_values(f_tck,datatoshow,clim, thetitle,cmap);
ax = gca; ch = ax.Colorbar; ch.Ticks = clim;
view(0,-270);
subplot(322);
thetitle = ['2 ' var ' ' hemis{2} ' ctrl'];
datatoshow = squeeze(nanmean(fullM(:,:,2,varn,groupidx==1),5));
h = displasia_show_streamlines_with_values(f_tck,datatoshow,clim, thetitle,cmap);
ax = gca; ch = ax.Colorbar; ch.Ticks = clim;


subplot(323);
thetitle = ['3 ' var ' ' hemis{1} ' bcnu'];
datatoshow = squeeze(nanmean(fullM(:,:,1,varn,groupidx==2),5));
h = displasia_show_streamlines_with_values(f_tck,datatoshow,clim, thetitle,cmap);
ax = gca; ch = ax.Colorbar; ch.Ticks = clim;
view(0,-270);
subplot(324);
thetitle = ['4 ' var ' ' hemis{2} ' bcnu'];
datatoshow = squeeze(nanmean(fullM(:,:,2,varn,groupidx==2),5));
h = displasia_show_streamlines_with_values(f_tck,datatoshow,clim, thetitle,cmap);
ax = gca; ch = ax.Colorbar; ch.Ticks = clim;


subplot(325);
Mctrl = squeeze(nanmean(fullM(:,:,1,varn,groupidx==1),5));
Mbcnu = squeeze(nanmean(fullM(:,:,1,varn,groupidx==2),5));
local_histogram(Mctrl(:),Mbcnu(:),clim,hemis{1})

subplot(326);
Mctrl = squeeze(nanmean(fullM(:,:,2,varn,groupidx==1),5));
Mbcnu = squeeze(nanmean(fullM(:,:,2,varn,groupidx==2),5));
local_histogram(Mctrl(:),Mbcnu(:),clim,hemis{2})

set(gcf,'Color','k')
set(gcf, 'InvertHardcopy', 'off');

if doSavePlot
  svgout = fullfile(dirfigs,'svg',[var '_averages.svg']);
  pngout = fullfile(dirfigs,'png',[var '_averages.png']);
  drawnow;
  fprintf(1,'Saving file %s\n',svgout);
  saveas(gcf, svgout);
  saveas(gcf, pngout);
end

end
