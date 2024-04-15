function h_fig = displasia_oli_4plots(metric,climval,climdif,pthresh,hemi,figuresfolder);

%fh = figure('units','normalized','outerposition',[0 0 1 1]);
h_fig = figure;

txtdir = '/misc/sherrington2/Olimpia/proyecto/stats_images/mean/txt/';
f_tck = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';

f_txt_ctrl = [txtdir metric '/mean_' metric '_' hemi '_ctrl.txt'];
mean_ctrl = displasia_oli_read_txt(f_txt_ctrl);
f_txt_bcnu = [txtdir metric '/mean_' metric '_' hemi '_bcnu.txt'];
mean_bcnu = displasia_oli_read_txt(f_txt_bcnu);
mean_diff = mean_bcnu - mean_ctrl;
f_txt_p = ['/misc/sherrington2/Olimpia/proyecto/stats_images/t de Student/txt/' metric '/' metric '_' hemi '_mtx_' pthresh '.txt'];
p     = displasia_oli_read_txt(f_txt_p);

% prepare colormaps
cmapVal = cbrewer('seq','YlGnBu',100, 'spline');
cmapVal = flipdim(cmapVal,1);
cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
cmap_div = flipdim(cmap_div,1);
cmap_warm = uint8(cbrewer('seq','YlOrBr',128,'spline') .* 255); cmap_warm = flip(cmap_warm,1);
cmap_cool = uint8(cbrewer('seq','YlGnBu',128,'spline') .* 255); cmap_cool = flip(cmap_cool,1);
cmap_pval = hot(128); cmap_pval = flip(cmap_pval,1);

clim = climval;

subplot(2,2,1);
h = displasia_show_streamlines_with_values(f_tck,mean_ctrl ,clim, f_txt_ctrl, cmapVal);
subplot(2,2,2);
h = displasia_show_streamlines_with_values(f_tck,mean_bcnu ,clim, f_txt_bcnu, cmapVal);
subplot(2,2,3);
clim = climdif;
h = displasia_show_streamlines_with_values(f_tck,mean_diff ,clim, 'mean diff', cmap_div);
subplot(2,2,4);
clim = [0 str2num(['0.' pthresh])];
h = displasia_show_streamlines_with_values(f_tck, p ,clim, f_txt_p, cmap_pval);


set(h_fig,'units','normalized','outerposition',[0 0 1 1])
      f_svg = fullfile(figuresfolder,'svg',[metric '_' hemi '_p' pthresh '.svg']);
      f_png = fullfile(figuresfolder,'png',[metric '_' hemi '_p' pthresh '.png']);
      set(h_fig, 'InvertHardcopy', 'off');
      fprintf(1,'  Saving %s\n',f_svg)
      saveas(h_fig,f_svg);
      fprintf(1,'  Saving %s\n',f_png)
      saveas(h_fig,f_png);
