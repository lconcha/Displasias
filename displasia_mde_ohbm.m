% scripts to create figures for OHBM2024 with Olimpia results

[status,hname]= unix('hostname');
hname = deblank(hname)

switch hname
    case 'lauterbur'
        addpath('/home/inb/soporte/lanirem_software/mrtrix3/matlab/')
        f_tck = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
        figuresfolder = '/misc/mansfield/lconcha/exp/displasia/paraOHBM2024/figs/';
        f_metrics = '/misc/nyquist/lconcha/displasia_AES2021/displasia/metrics_and_ranges.txt';
        f_ranges  = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/ranges.csv';
        addpath /home/inb/lconcha/fmrilab_software/tools/matlab/toolboxes/cbrewer/cbrewer
        f_results = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/results/RESULTS.mat';
        dir_mahal = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/resultados_aylin/distancia_mahalanobis/';
        dir_txt = '/misc/sherrington2/Olimpia/proyecto/stats_images/';
       
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


txtdir = '/misc/sherrington2/Olimpia/proyecto/stats_images/mean/txt/';


hemis = ['l' 'r'];
ps    = {char('01') char('05')};

for i = 1 : length(hemis)
    for j = 1 : length(ps)
        hemi = hemis(i);
        pthresh = ps{i};

        fh = displasia_oli_4plots('FA',[0 0.6],[-0.2 0.2],pthresh,hemi,figuresfolder);
        close(fh)
        fh = displasia_oli_4plots('Cc',[0 0.6],[-0.2 0.2],pthresh,hemi,figuresfolder);
        close(fh)
        fh = displasia_oli_4plots('uFA',[0 1],[-0.2 0.2],pthresh,hemi,figuresfolder);
        close(fh)
        fh = displasia_oli_4plots('ad',[0 2],[-0.5 0.5],pthresh,hemi,figuresfolder);
        close(fh)
        fh = displasia_oli_4plots('rd',[0 2],[-0.5 0.5],pthresh,hemi,figuresfolder);
        close(fh)
        fh = displasia_oli_4plots('MD',[0 2],[-0.5 0.5],pthresh,hemi,figuresfolder);
        close(fh)

    end
end
