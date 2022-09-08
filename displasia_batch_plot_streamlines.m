


%addpath('/home/inb/lconcha/fmrilab_software/mrtrix3/matlab');
addpath('/home/lconcha/software/mrtrix_matlab/matlab');
addpath('/home/lconcha/software/cbrewer');

figuresfolder = '/datos/syphon/displasia/paraArticulo1/figures';

msize               = 100;
mygray              = [0.5 0.5 0.5];
mylightgray         = [0.8 0.8 0.8];
free_clim           = false;
pclus_threshold     = 0.05;
puncorr_threshold   = 0.05;


metrics = fieldnames(RESULTS.clusterstats);
comparisons = {'AgtB','AltB'};
for m = 1 : length(metrics)
    for c = 1 : length(comparisons)
      comparison = comparisons{c};
      metric = metrics{m};
  
      fprintf(1,'%d %d %s %s\n',m,c,metric,comparison);


      h_fig = figure('units','normalized','outerposition',[0.25 0.25 0.5 0.5]);
      displasia_plot_streamlines(RESULTS,metric,comparison,msize,free_clim,pclus_threshold,puncorr_threshold)
      f_svg = fullfile(figuresfolder,'svg',[metric '_' comparison '.svg']);
      f_png = fullfile(figuresfolder,'png',[metric '_' comparison '.png']);
      set(h_fig, 'InvertHardcopy', 'off');
      saveas(h_fig,f_svg);
      saveas(h_fig,f_png);
      close(h_fig);
    end
end



