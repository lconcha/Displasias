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

s = 25;
d = 5;
idx_ctrl = RESULTS.data.idx_ctrl;
idx_bcnu = RESULTS.data.idx_bcnu;

takeTheseMetrics = zeros(21,1);
takeTheseMetrics([2 10 11 12 13 14]) = 1;
takeTheseMetrics = logical(takeTheseMetrics);

values_ctrl = squeeze(RESULTS.data.DATA(s,d,idx_ctrl,takeTheseMetrics));
values_bcnu = squeeze(RESULTS.data.DATA(s,d,idx_bcnu,takeTheseMetrics));
values_all  = squeeze(RESULTS.data.DATA(s,d,:,takeTheseMetrics));


d_ctrl = values_ctrl ./ mean(values_all);
d_bcnu = values_bcnu ./ mean(values_all);
m = mahal(d_bcnu,d_ctrl);

scatter(d_ctrl(:,1), d_ctrl(:,2), 50, 'filled','MarkerFaceColor','k'); hold on
scatter(d_bcnu(:,1), d_bcnu(:,2), 50, m , 'filled')



SE = strel('diamond',1); % create a 4-conn neighborhood

nStreamlines = size(RESULTS.data.DATA,1);
nDepths      = size(RESULTS.data.DATA,2);
for s = 1 : nStreamlines
    for d = 1 : nDepths
       im = zeros(nStreamlines,nDepths);
       im(s,d) = 1;
       imd = imdilate(logical(im),SE);
       [i,j] = ind2sub(size(imd),find(imd));
       %I = zeros(1,nStreamlines); I(i) = 1; I = logical(I);
       %J = zeros(1,nDepths);      J(j) = 1; J = logical(J);
       values_ctrl = squeeze(RESULTS.data.DATA(i,j,idx_ctrl,takeTheseMetrics)); % esto está mal, quiero la coincidencia i,j
       values_bcnu = squeeze(RESULTS.data.DATA(i,j,idx_bcnu,takeTheseMetrics));
       values_all  = squeeze(RESULTS.data.DATA(i,j,:,takeTheseMetrics));
    end
end


