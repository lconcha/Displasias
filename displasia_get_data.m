% 02 sep 2022
% lconcha
addpath /misc/mansfield/lconcha/software/Displasias
addpath /home/inb/lconcha/fmrilab_software/tools/matlab/toolboxes/cbrewer/cbrewer
addpath /home/inb/lconcha/fmrilab_software/tools/matlab/

f_csv = '/misc/nyquist/dcortes_aylin/displaciasCorticales/derivatives/C13_open_data/rat_dataset.csv';
rat_table = readtable(f_csv);
d_deriv1 = '/misc/nyquist/dcortes_aylin/displaciasCorticales/derivatives/';
d_deriv2 = '/ses-P30/mapas-streamlines-20';

f_metrics = '/misc/nyquist/lconcha/displasia_AES2021/displasia/metrics_and_ranges.txt';
f_ranges  = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/ranges.csv';

metrics_table = readtable(f_ranges);
metrics = metrics_table.fileName;




doPlots = true;
doStats = true;
nperms     = 1000;
ndiffperms = 1000;
doPerms = true;

%% Find files and figure out who to exclude
for r = 1:length(rat_table.rat_id)
    thisrat = cell2mat(rat_table.rat_id(r));
    OK = true;
    for v = 1 : length(metrics)
        vartxt = metrics{v};
        f_data = fullfile(d_deriv1,thisrat,d_deriv2,vartxt);
        if isfile(f_data)
          OK = 1;
        else
          fprintf(1,'ERROR, Cannot find %s\n',f_data);
          OK = false;
        end
    end
    if OK
       fprintf(1,'%s OK\n',thisrat)
       rat_table.OK(r) = 1;
    else
       rat_table.OK(r) = 0;
    end
end


%% clean up the table
rat_table    = rat_table(rat_table.OK == 1,:);
nRats        = height(rat_table);
nMetrics     = length(metrics);
nStreamlines = 50;
nDepths      = 10;
DATA         = zeros(nStreamlines,nDepths,nRats,nMetrics);
for r = 1:length(rat_table.rat_id)
    thisrat = cell2mat(rat_table.rat_id(r));
    OK = true;
    for v = 1 : length(metrics)
        vartxt   = metrics{v};
        f_data   = fullfile(d_deriv1,thisrat,d_deriv2,vartxt);
        dd       = load(f_data);
        thisdata = dd(1:3:end,1:2:end); % skip streamlines and points
        DATA(:,:,r,v) = thisdata;
    end
end

n1 = ceil(sqrt(nMetrics));
n2 = ceil(nMetrics) / n1;