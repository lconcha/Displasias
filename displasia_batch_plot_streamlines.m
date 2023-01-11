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
        addpath /home/lconcha/software/Displasias/
end


msize               = 100;
mygray              = [0.5 0.5 0.5];
mylightgray         = [0.8 0.8 0.8];
free_clim           = false;
pclus_threshold     = 0.05;
puncorr_threshold   = 0.05;

h_fig = figure('units','normalized','outerposition',[0 0 0.5 0.5]);

metrics = fieldnames(RESULTS.clusterstats);
comparisons = {'AgtB','AltB'};
for m = 1 : length(metrics)
    for c = 1 : length(comparisons)
      comparison = comparisons{c};
      metric = metrics{m};
  
      fprintf(1,'%d %d %s %s\n',m,c,metric,comparison);


      
      displasia_plot_streamlines(f_tck,RESULTS,metric,comparison,msize,free_clim,pclus_threshold,puncorr_threshold)
      drawnow;

      f_svg = fullfile(figuresfolder,'svg',[metric '_' comparison '.svg']);
      f_png = fullfile(figuresfolder,'png',[metric '_' comparison '.png']);
      set(h_fig, 'InvertHardcopy', 'off');
      saveas(h_fig,f_svg);
      saveas(h_fig,f_png);
      clf;
    end
end

h = displasia_show_streamlines_with_values(f_tck, mean(MAHAL(:,:,idx_bcnu),3)  ,[], 'Mahal');
set(gca,'Clim',[0 50]);
f_svg = fullfile(figuresfolder,'svg',['mahalanobis.svg']);
f_png = fullfile(figuresfolder,'png',['mahalanobis.png']);
set(h_fig, 'InvertHardcopy', 'off');
saveas(h_fig,f_svg);
saveas(h_fig,f_png);
clf;
