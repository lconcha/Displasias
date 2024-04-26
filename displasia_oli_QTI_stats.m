
%%%% NOT FINISHED YET!!! April 17 2024

%%%%%%% OPTIONS %%%%%%%%%%%%%%%
results_folder           = '/misc/sherrington2/Olimpia/proyecto/qti+/csv_metrics_p';
clusterformingpthreshold = 0.01;
clusterpthreshold        = 0.05;
ndiffperms               = 5000;% Use 0 for permuting only at cluster level (ttests at vertex level). Use >0 for permutation tests at vertex  and cluster levels.
nclusperms               = 5000;
conn                     = 8;
doPlot                   = true;
rng(1);                  % seed.
figuresfolder            =  '/misc/mansfield/lconcha/exp/displasia/oli_OHBM2024/';
%f_tck_l = 'example_files/R82B_l_perm.tck';
%f_tck_r = 'example_files/R82B_r_perm.tck';
f_tck_l  = 'example_files/Fisher_l_out_resampled_10.tck';
f_tck_r  = 'example_files/Fisher_r_out_resampled_10.tck';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






D = dir([results_folder '/*.csv']);
for f = 1 : length(D)
    for hemi = 1 : 2
        f_csv = fullfile(results_folder, D(f).name);
        DATA = displasia_oli_table2matrix(f_csv);
        if hemi == 1
           f_tck  = f_tck_l;
           s_hemi = 'l';
        else
           f_tck  = f_tck_r;
           s_hemi = 'r';
        end
        
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
                        doPlot,...
                        f_tck);
        
         permstring = [num2str(ndiffperms) '-diffperm_' num2str(nclusperms) '-clusperm'];

         f_svg = fullfile(figuresfolder,['01_' permstring '_'  char(DATA.Metric) '-' s_hemi '.svg']);
         f_png = fullfile(figuresfolder,['01_' permstring '_' char(DATA.Metric) '-' s_hemi '.png']);
         set(gcf, 'InvertHardcopy', 'off','Renderer','painters');
         saveas(gcf, f_svg);
         saveas(gcf, f_png);
         close(gcf)


    end

end









