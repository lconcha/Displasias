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


    case 'syphon'
        addpath('/home/lconcha/software/mrtrix_matlab/matlab');
        f_tck = '/datos/syphon/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
        figuresfolder = '/datos/syphon/displasia/paraArticulo1/figures';
        f_metrics = '/datos/syphon/displasia/paraArticulo1/metrics_and_ranges.txt';
        f_ranges  = '/datos/syphon/displasia/paraArticulo1/ranges.csv';
        addpath /home/lconcha/software/cbrewer
        addpath /home/lconcha/software/Displasias/
        f_results = '/datos/syphon/displasia/paraArticulo1/RESULTS.mat';
end


load(f_results);


thetitle = 'FA';
m = 2;
clim = [0.0 0.4];
%clim = [];
idx_ctrl = RESULTS.data.idx_ctrl;
values = mean(squeeze(RESULTS.data.DATA(:,:,idx_ctrl,m)), 3);
h = displasia_show_streamlines_with_values(f_tck,values,clim,thetitle);
    f_svg = fullfile(figuresfolder,'svg',[thetitle '_exampleSubject.svg'])
    f_png = fullfile(figuresfolder,'png',[thetitle '_exampleSubject.png']);
    set(h, 'InvertHardcopy', 'off');
    saveas(h,f_svg);
    saveas(h,f_png);

thetitle = 'FAperp';
m = 11;
clim = [0.6 0.8];
%clim = [];
idx_ctrl = RESULTS.data.idx_ctrl;
values = mean(squeeze(RESULTS.data.DATA(:,:,idx_ctrl,m)), 3);
h = displasia_show_streamlines_with_values(f_tck,values,clim,thetitle);
    f_svg = fullfile(figuresfolder,'svg',[thetitle '_exampleSubject.svg'])
    f_png = fullfile(figuresfolder,'png',[thetitle '_exampleSubject.png']);
    set(h, 'InvertHardcopy', 'off');
    saveas(h,f_svg);
    saveas(h,f_png);

thetitle = 'FApar';
m = 12;
clim = [0.6 0.8];
%clim = [];
idx_ctrl = RESULTS.data.idx_ctrl;
values = mean(squeeze(RESULTS.data.DATA(:,:,idx_ctrl,m)), 3);
h = displasia_show_streamlines_with_values(f_tck,values,clim,thetitle);
    f_svg = fullfile(figuresfolder,'svg',[thetitle '_exampleSubject.svg'])
    f_png = fullfile(figuresfolder,'png',[thetitle '_exampleSubject.png']);
    set(h, 'InvertHardcopy', 'off');
    saveas(h,f_svg);
    saveas(h,f_png);

thetitle = 'MDperp';
m = 13;
clim = [0.0002 0.0013];
%clim = [];
idx_ctrl = RESULTS.data.idx_ctrl;
values = mean(squeeze(RESULTS.data.DATA(:,:,idx_ctrl,m)), 3);
h = displasia_show_streamlines_with_values(f_tck,values,clim,thetitle);
    f_svg = fullfile(figuresfolder,'svg',[thetitle '_exampleSubject.svg'])
    f_png = fullfile(figuresfolder,'png',[thetitle '_exampleSubject.png']);
    set(h, 'InvertHardcopy', 'off');
    saveas(h,f_svg);
    saveas(h,f_png);

thetitle = 'MDpar';
m = 14;
clim = [0.0002 0.0013];
%clim = [];
idx_ctrl = RESULTS.data.idx_ctrl;
values = mean(squeeze(RESULTS.data.DATA(:,:,idx_ctrl,m)), 3);
h = displasia_show_streamlines_with_values(f_tck,values,clim,thetitle);
    f_svg = fullfile(figuresfolder,'svg',[thetitle '_exampleSubject.svg'])
    f_png = fullfile(figuresfolder,'png',[thetitle '_exampleSubject.png']);
    set(h, 'InvertHardcopy', 'off');
    saveas(h,f_svg);
    saveas(h,f_png);