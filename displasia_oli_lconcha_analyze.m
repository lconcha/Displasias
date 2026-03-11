% lconcha, Nov 2025

addpath /misc/lauterbur2/lconcha/code/cbrewer/cbrewer/

%% Parameters
figuresdir               = '/misc/lauterbur2/lconcha/exp/displasia/olimpia/figures_lconcha.feb2026/';
resultsdir               = '/misc/lauterbur2/lconcha/exp/displasia/olimpia/results_lconcha/';
loadprevious             = true;
overwrite                = false;
ndiffperms               = 1000;
nclusperms               = 5000;
clusterformingpthreshold = 0.01;
clusterpthreshold        = 0.05;
conn                     = 8;
f_tck                    = 'example_files/streamlines_50_10.tck';
file_results             = fullfile(resultsdir,'results_lconcha.mat');


%% Things to do
doPlotAverages          = false;
doCohenSubPlots         = false;
doCohenPlots            = true;
doBoxplots              = false;

%% Load data
displasia_oli_load_all_metrics

%% Plot averages
if doPlotAverages
    for varn = 1 : length(vars)
        h = displasia_oli_plot_average_oneMetric(fullM,vars,varn,hemis,groupidx,figuresdir);
        clf
    end
end

ctrl.name  = 'ctrl';
bcnu.name  = 'bcnu';

if loadprevious
    fprintf('Loading previous results from %s\n',file_results);
    load(file_results);
else
    for varn = 1 : length(vars)
        for hemi = 1 : length(hemis)
            metricName = vars{varn};
            heminame = hemis{hemi};
            fprintf(1,'Working on variable %s in %s hemisphere',metricName,heminame);
            
            ctrl.data = squeeze(fullM(:,:,hemi,varn,groupidx==1));
            bcnu.data = squeeze(fullM(:,:,hemi,varn,groupidx==2));
            pcluster.(metricName).(heminame) = displasia_oli_cluster_perm_2D(ctrl,bcnu,...
                                ndiffperms,nclusperms,...
                                clusterformingpthreshold,...
                                clusterpthreshold,...
                                conn,...
                                metricName,...
                                doCohenSubPlots,...
                                f_tck);
            pcluster.(metricName).(heminame).hemi     = hemi;
           
        end
    end
end



fprintf(1,'Overwrite:  ')
overwrite
if overwrite
  clear overwrite loadprevious;
  fprintf(1,'HEY! Will overwrite previous results\n');
  save(file_results)
elseif exist(file_results,'file') & ~overwrite
  fprintf('HEY! Will NOT overwrite previous results\n');
else
  clear overwrite loadprevious;
  fprintf('Saving results to %s\n',file_results)
  save(file_results)
end


varnames = fieldnames(pcluster);
if doCohenPlots
    for v = 1 : length(varnames)
        thisvarname = varnames{v, 1};
        for h = 1 : length(hemis)
            subplot(1,2,h);
            hf = displasia_oli_plot_just_cohen(pcluster,thisvarname,hemis{h});
        end
        f_svg = fullfile(figuresdir,sprintf('%s/%s_dcohen.%s',"svg",thisvarname,"svg"));
        f_png = fullfile(figuresdir,sprintf('%s/%s_dcohen.%s',"png",thisvarname,"png"));
          drawnow;
          set(gcf,'Renderer', 'painters','Position', [414 620 2147 592]);
          set(gcf,'Color','k')
          set(gcf, 'InvertHardcopy', 'off');
          fprintf(1,'Saving file %s\n',f_svg);
          saveas(gcf, f_svg);
          saveas(gcf, f_png);
        clf;

    end
end


if doBoxplots
 for v = 1 : length(varnames)
        thisvarname = varnames{v, 1};
        for h = 1 : length(hemis)
            thishemi = hemis{h};
            hf(h) = displasia_oli_plot_just_boxplot(pcluster,thisvarname,varnames,thishemi,hemis,fullM,groupidx,figuresdir);
            %set(gca,'YLim',vars{v,2})
        end
        clf;

    end
end