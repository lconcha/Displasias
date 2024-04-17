
%%%% NOT FINISHED YET!!! April 17 2024

%%%%%%% OPTIONS %%%%%%%%%%%%%%%
f_csv = 'example_files/uFAp_long.csv';
clusterformingpthreshold = 0.01;
clusterpthreshold        = 0.05;
ndiffperms               = 5000;% Use 0 for permuting only at cluster level (ttests at vertex level). Use >0 for permutation tests at vertex  and cluster levels.
nclusperms               = 1000;
conn                     = 8;
doPlot                   = true;
rng(1);                  % seed.
hemi                     = 1; % 1=left, 2=right
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


DATA = displasia_oli_table2matrix(f_csv);

groupA.data = DATA.Values(:,:,DATA.index.ctrl,hemi);
groupA.name = 'ctrl';
groupB.data = DATA.Values(:,:,DATA.index.bcnu,hemi);
groupB.name = 'bcnu';
thistitle   = char(DATA.Metric);

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