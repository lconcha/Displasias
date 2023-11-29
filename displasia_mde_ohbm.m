% scripts to create figures for OHBM2024 with Olimpia results


switch hname
    case 'mansfield'
        addpath('/home/inb/soporte/lanirem_software/mrtrix3/matlab/')
        f_tck = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
        figuresfolder = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/results/figures';
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



f_txt = '/misc/sherrington2/Olimpia/proyecto/stats_images/mean/txt/FA/mean_FA_l_ctrl.txt';
fid = fopen(f_txt);

nPoints = 50;
nStreamlines = 10;
linenum = 0;
data = nan(nStreamlines,nPoints);
strnum = 0;
while true
    linenum = linenum +1;
    if linenum <2 ; fprintf(1,'Skipping header\n');continue;end
    tline = fgets(fid);
    fprintf(1,'linenum %d : %s\n',linenum, tline)
    if tline == -1; fprintf(1,'End of file\n');break;end
    strline = regexprep(tline,'".*",','');
    eval(['m = ['  strline  ' ];' ])
    strnum = strnum +1;
    fprintf(1,'Adding data to streamline %d\n',strnum)
    data(strnum,:) = m;
    disp(m(1:3));
end
fclose(fid);


values = data';
clim = [0 1];
thetitle = 'test';
cmap = cbrewer('seq','YlGnBu',100);
cmap = flipdim(cmap,1);
h = displasia_show_streamlines_with_values(f_tck,values,clim, thetitle, cmap);