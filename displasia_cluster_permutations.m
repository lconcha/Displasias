
%%%%%%% OPTIONS %%%%%%%%%%%%%%%
clusterformingpthreshold = 0.05;
clusterpthreshold        = 0.05;
ndiffperms               = 5000;
nclusperms               = 5000;
conn                     = 4;
doPlot                   = true;
rng(1);                  % seed. Note: added this line only AFTER the first 20 metrics (and mahal) were analyzed, so it is pointless. My bad.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



idx_ctrl = rat_table.group == "Control";
idx_bcnu = rat_table.group == "BCNU";


figure('units','normalized','outerposition',[0 0 1 1]);
tic
for m = 21% : nMetrics
    data_ctrl.data = DATA(:,:,idx_ctrl,m);
    data_ctrl.name = 'ctrl';
    data_bcnu.data = DATA(:,:,idx_bcnu,m);
    data_bcnu.name = 'bcnu';
    thistitle = cell2mat(metrics_table.shortName(m));
    thisfname = ['results/clusterstats_' thistitle '.svg'];
    fprintf(1,' %d/%d : %s\n',m,nMetrics,thistitle);
    pcluster = cluster_perm_2D(data_ctrl,data_bcnu,...
                    ndiffperms,nclusperms,...
                    clusterformingpthreshold,...
                    clusterpthreshold,...
                    conn,...
                    thistitle,...
                    doPlot);
    RESULTS.clusterstats.(thistitle) = pcluster;
    drawnow;
    saveas(gcf,thisfname);
    close(gcf)
end

RESULTS.parameters.clusterformingpthreshold =  clusterformingpthreshold;
RESULTS.parameters.clusterpthreshold        = clusterpthreshold;
RESULTS.parameters.ndiffperms               = ndiffperms;
RESULTS.parameters.nclusperms               = nclusperms;
RESULTS.parameters.conn                     = conn;
RESULTS.data.DATA                           = DATA;
RESULTS.data.rat_table                      = rat_table;
RESULTS.data.metrics                        = metrics;
RESULTS.data.idx_ctrl                       = idx_ctrl;
RESULTS.data.idx_bcnu                       = idx_bcnu;
RESULTS.data.filenames                      = allFileNames;

fprintf(1,'Saving results\n')
save('results/RESULTS','RESULTS');
toc