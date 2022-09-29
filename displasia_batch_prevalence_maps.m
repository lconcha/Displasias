%addpath('/home/inb/lconcha/fmrilab_software/mrtrix3/matlab');
addpath('/home/lconcha/software/mrtrix_matlab/matlab');
addpath('/home/lconcha/software/cbrewer');

figuresfolder = '/datos/syphon/displasia/paraArticulo1/figures';


metrics = fieldnames(RESULTS.clusterstats);
for m = 1 : length(metrics)
      h_fig = figure('units','normalized','outerposition',[0.25 0.25 0.5 0.5]);
      displasia_prevalence_maps(RESULTS,m)
      f_svg = fullfile(figuresfolder,'svg',[metric '_prev.svg']);
      f_png = fullfile(figuresfolder,'png',[metric '_prev.png']);
      set(h_fig, 'InvertHardcopy', 'off');
      saveas(h_fig,f_svg);
      saveas(h_fig,f_png);
      close(h_fig);

end



