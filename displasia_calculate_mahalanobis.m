[status,hname]= unix('hostname');
hname = deblank(hname);

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

takeTheseMetrics = [1 2 10 11 12 13 14];
idx_ctrl = RESULTS.data.idx_ctrl;
idx_bcnu = RESULTS.data.idx_bcnu;


SE = strel('diamond',1); % create a 4-conn neighborhood

nStreamlines = size(RESULTS.data.DATA,1);
nDepths      = size(RESULTS.data.DATA,2);
nRats        = size(RESULTS.data.DATA,3);
nMetrics     = length(takeTheseMetrics);

MAHAL   = zeros(nStreamlines,nDepths,nRats);
for s = 1 : nStreamlines
    fprintf(1,'%d of %d\n',s,nStreamlines);
    for d = 1 : nDepths
       im = zeros(nStreamlines,nDepths);
       im(s,d) = 1;
       imd = imdilate(logical(im),SE);
       [i,j] = ind2sub(size(imd),find(imd));
       
       npix = sum(imd(:));

       nbhood = zeros(npix,nRats,nMetrics);
       for p = 1 : npix
          nbhood(p,:,:) = squeeze(RESULTS.data.DATA(i(p),j(p),:,takeTheseMetrics));
       end
       nbhood = squeeze(mean(nbhood,1)); % average values for each rat.
       
       values_ctrl = nbhood(idx_ctrl,:);% values_ctrl = reshape(values_ctrl, npix*sum(idx_ctrl),nMetrics);
       values_bcnu = nbhood(idx_bcnu,:);% values_bcnu = reshape(values_bcnu, npix*sum(idx_bcnu),nMetrics);
       values_all  = nbhood; %reshape(nbhood,  npix* nRats,       nMetrics);

       d_ctrl = values_ctrl ./ mean(values_all);
       d_bcnu = values_bcnu ./ mean(values_all);
       d_all  = values_all ./ mean(values_all);
       m_b = mahal(d_bcnu,d_ctrl);
       m_c = mahal(d_ctrl,d_ctrl);
       m_a = mahal(d_all, d_ctrl);
       %scatter(d_ctrl(:,1), d_ctrl(:,2), 50, m_c, 'Marker','x'); hold on
       %scatter(d_bcnu(:,1), d_bcnu(:,2), 50, m_b , 'filled')

       MAHAL(s,d,:) = m_a;
    end
end



displasia_show_streamlines_with_values(f_tck, mean(MAHAL(:,:,idx_bcnu),3)  ,[], 'Mahal')
