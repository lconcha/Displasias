

[status,hname]= unix('hostname');
hname = deblank(hname)

switch hname
    case 'mansfield'
        addpath('/home/inb/lconcha/fmrilab_software/mrtrix3/matlab');
        f_tck = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
        figuresfolder = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/results/figures';
        f_metrics = '/misc/nyquist/lconcha/displasia_AES2021/displasia/metrics_and_ranges.txt';
        f_ranges  = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/ranges.csv';
        addpath /home/inb/lconcha/fmrilab_software/tools/matlab/toolboxes/cbrewer/cbrewer
        f_results = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/results/RESULTS.mat';
        dir_mahal = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/resultados_aylin/distancia_mahalanobis/';
       
    case 'syphon'
        addpath('/home/lconcha/software/mrtrix_matlab/matlab');
        f_tck = '/datos/syphon/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
        figuresfolder = '/datos/syphon/displasia/paraArticulo1/figures';
        f_metrics = '/datos/syphon/displasia/paraArticulo1/metrics_and_ranges.txt';
        f_ranges  = '/datos/syphon/displasia/paraArticulo1/ranges.csv';
        addpath /home/lconcha/software/cbrewer
        f_results = '/datos/syphon/displasia/paraArticulo1/RESULTS.mat';
end
metrics_table = readtable(f_ranges);
tck = read_mrtrix_tracks(f_tck);

load(f_results)


% populate the mahal results
nRats = length(RESULTS.data.rat_table.rat_id);
MAHAL = zeros(50,10,nRats);
for r = 1 : nRats
  thisrat = RESULTS.data.rat_table.rat_id{r};
  f_thismahal = [dir_mahal,thisrat,'.txt'];
  thismahal = load(f_thismahal);
  thismahal = thismahal(1:3:end,:); % only get 50 streamlines
  MAHAL(:,:,r) = thismahal;
end

mygray              = [0.5 0.5 0.5];
mylightgray         = [0.8 0.8 0.8];
this_marker_size    = 50;
metrics             = fieldnames(RESULTS.clusterstats);

% prepare colormaps
cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
cmap_warm = uint8(cbrewer('seq','YlOrBr',128,'spline') .* 255); cmap_warm = flip(cmap_warm,1);
%cmap_cool = uint8(cbrewer('seq','PuBuGn',128,'spline') .* 255); cmap_cool = flip(cmap_cool,1);
cmap_cool = uint8(cbrewer('seq','YlGnBu',128,'spline') .* 255); cmap_cool = flip(cmap_cool,1);
cmap_pval = hot(128); cmap_pval = flip(cmap_pval,1);
%cmap_mahal = uint8(cbrewer('seq','PuRd',128, 'spline') .* 255); cmap_mahal = flip(cmap_mahal,1);
cmap_mahal = cmap_cool;

thisrange = [0 6];

h_fig = figure('units','normalized','outerposition',[0 0 1 1]);
    
    
    
mean_ctrl = mean(MAHAL(:,:,RESULTS.data.idx_ctrl),3);
mean_bcnu = mean(MAHAL(:,:,RESULTS.data.idx_bcnu),3);
mean_diff = mean_ctrl - mean_bcnu;
   
subplot(2,2,1);
    for st = 1 : length(tck.data)
        thisline            = tck.data{st};
        h_lines(st)         = plot(thisline(:,1),thisline(:,2), 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
        thismean            = mean_ctrl(st,:);
        h_scatterfilled(st) = scatter(thisline(:,1),thisline(:,2),this_marker_size,thismean,'filled');
        hold on
    end
    set(gca,'Clim',thisrange)
    set(gca,'colormap',cmap_mahal)
    view(180,270)
    grid off; axis off; axis equal
    hold off;
    set(gcf,'Color','k')
    h_colorbar = colorbar(gca,'Color',mygray);
    h_colorbar.Label.String = 'Mahalanobis distance';
    title('Mahalanobis | Control' ,'Color','w')

 subplot(2,2,2);
    for st = 1 : length(tck.data)
        thisline            = tck.data{st};
        h_lines(st)         = plot(thisline(:,1),thisline(:,2), 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
        thismean            = mean_bcnu(st,:);
        h_scatterfilled(st) = scatter(thisline(:,1),thisline(:,2),this_marker_size,thismean,'filled');
        hold on
    end
    set(gca,'Clim',thisrange)
    set(gca,'colormap',cmap_mahal)
    view(180,270)
    grid off; axis off; axis equal
    hold off;
    set(gcf,'Color','k')
    h_colorbar = colorbar(gca,'Color',mygray);
    h_colorbar.Label.String = 'Mahalanobis distance';
    title('Mahalanobis | BCNU','Color','w')

  subplot(2,2,4);
    for st = 1 : length(tck.data)
        thisline            = tck.data{st};
        h_lines(st)         = plot(thisline(:,1),thisline(:,2), 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
        thismean            = mean_diff(st,:);
        h_scatterfilled(st) = scatter(thisline(:,1),thisline(:,2),this_marker_size,thismean,'filled');
        hold on
    end
    lims = get(gca,'Clim');
    newlims = [max(abs(lims))*-1 max(abs(lims))];
    set(gca,'Clim',newlims);
    set(gca,'colormap',cmap_div)
    view(180,270)
    grid off; axis off; axis equal
    hold off;
    set(gcf,'Color','k')
    h_colorbar = colorbar(gca,'Color',mygray);
    title('Mahalanobis | Ctrl-BCNU','Color','w')

  subplot(2,2,3)
    nbins = 100;
    maxval = 20;
    edges = linspace(0,maxval,nbins);
    data_ctrl = MAHAL(:,:,RESULTS.data.idx_ctrl);
    data_bcnu = MAHAL(:,:,RESULTS.data.idx_bcnu);
    mybcnucolor = cmap_mahal(length(cmap_mahal)./2,:);
    histogram(data_ctrl(:),edges, 'Normalization','probability','DisplayStyle', 'stairs', 'EdgeColor',mygray,'LineWidth',2); hold on
    histogram(data_bcnu(:),edges, 'Normalization','probability','DisplayStyle', 'stairs', 'EdgeColor',mybcnucolor,'LineWidth',2); hold off
    title('Mahalanobis distance','Color','w')
    set(gca,'Color','k','XColor','w', 'YColor','w','box', 'off')
    legend('Control','BCNU','TextColor','w')




f_svg = fullfile(figuresfolder,'svg','mahalanobis_average.svg')
f_png = fullfile(figuresfolder,'png','mahalanobis_average.png');
set(h_fig, 'InvertHardcopy', 'off');
saveas(h_fig,f_svg);
saveas(h_fig,f_png);


figure;
%%%%%%% OPTIONS %%%%%%%%%%%%%%%
clusterformingpthreshold = RESULTS.parameters.clusterformingpthreshold;
clusterpthreshold        = RESULTS.parameters.clusterpthreshold;
ndiffperms               = RESULTS.parameters.ndiffperms;
nclusperms               = RESULTS.parameters.nclusperms;
conn                     = RESULTS.parameters.conn;
doPlot                   = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_ctrl.data = MAHAL(:,:,RESULTS.data.idx_ctrl);
data_ctrl.name = 'ctrl';
data_bcnu.data = MAHAL(:,:,RESULTS.data.idx_bcnu);
data_bcnu.name = 'bcnu';
thistitle = 'Mahalanobis';
thisfname = ['results/clusterstats_' thistitle '.svg'];
pcluster = cluster_perm_2D(data_ctrl,data_bcnu,...
                ndiffperms,nclusperms,...
                clusterformingpthreshold,...
                clusterpthreshold,...
                conn,...
                thistitle,...
                doPlot);
RESULTS.clusterstats.mahal = pcluster;


%% plot
metric = 'mahal';
msize               = 100;
mygray              = [0.5 0.5 0.5];
mylightgray         = [0.8 0.8 0.8];
free_clim           = false;
pclus_threshold     = 0.05;
puncorr_threshold   = 0.05;
comparison          = 'AltB';
h_fig = figure('units','normalized','outerposition',[0 0 1 1 ]);
      displasia_plot_streamlines(RESULTS,metric,comparison,msize,free_clim,pclus_threshold,puncorr_threshold)
      f_svg = fullfile(figuresfolder,'svg',[metric '_' comparison '.svg']);
      f_png = fullfile(figuresfolder,'png',[metric '_' comparison '.png']);
      set(h_fig, 'InvertHardcopy', 'off');
      saveas(h_fig,f_svg);
      saveas(h_fig,f_png);
      close(h_fig);


