
clusterformingpthreshold = 0.05;
clusterpthreshold        = 0.05;
ndiffperms               = 500;
nclusperms               = 100;
conn                     = 4;
doPlot                   = true;

idx_ctrl = rat_table.group == "Control";
idx_bcnu = rat_table.group == "BCNU";


figure('units','normalized','outerposition',[0 0 1 1]);
%thismetric = metrics_table.shortName(m);
%RESULTS.
for m = 1 : nMetrics
    data_ctrl.data = DATA(:,:,idx_ctrl,m);
    data_ctrl.name = 'ctrl';
    data_bcnu.data = DATA(:,:,idx_bcnu,m);
    data_bcnu.name = 'bcnu';
    thistitle = cell2mat(metrics_table.shortName(m));
    thisfname = ['clusterstats_' thistitle '.png'];
    %clusters = displasia_cluster_param(data_ctrl,data_bcnu,0.05,0.05,ndiffperms,4,true,thistitle);
    %clusters = displasia_cluster_param(data_ctrl,data_bcnu,cfthresh,pthresh,nperms,conn,doPlot,thistitle);
    pcluster = cluster_perm_2D(data_ctrl,data_bcnu,...
                    ndiffperms,nclusperms,...
                    clusterformingpthreshold,...
                    clusterpthreshold,...
                    conn,...
                    thistitle,...
                    doPlot);
    RESULTS.(thistitle) = pcluster;
    drawnow;
    saveas(gcf,thisfname);
    close(gcf)
end

save RESULTS