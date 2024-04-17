
addpath(genpath('/home/lconcha/software/Displasias'));


%%%%%%% OPTIONS %%%%%%%%%%%%%%%
f_csv = 'example_files/uFAp_long.csv';
clusterformingpthreshold = 0.01;
clusterpthreshold        = 0.02;
ndiffperms               = 1000;
nclusperms               = 1000;
conn                     = 4;
doPlot                   = true;
rng(1);                  % seed. Note: added this line only AFTER the first 20 metrics (and mahal) were analyzed, so it is pointless. My bad.
hemi                     = 1; % 1=left, 2=right
thistitle                = 'test with uFA';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


DATA = displasia_oli_table2matrix(f_csv);

groupA.data = DATA.Values(:,:,DATA.index.ctrl,hemi);
groupA.name = 'ctrl';
groupB.data = DATA.Values(:,:,DATA.index.bcnu,hemi);
groupB.name = 'bcnu';

pcluster = displasia_oli_cluster_perm_2D(groupA,groupB,...
                ndiffperms,nclusperms,...
                clusterformingpthreshold,...
                clusterpthreshold,...
                conn,...
                thistitle,...
                doPlot);

subplot(331); set(gca,'CLim',[0 1])
subplot(332); set(gca,'CLim',[0 1])
subplot(333); set(gca,'CLim',[-0.2 0.2])