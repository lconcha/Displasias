% 29 ago 2022
% lconcha
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
nperms  = 1000;
doPerms = false;

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




%% Plot
if doPlots
    % prepare colormaps
    cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
    cmap_warm = uint8(cbrewer('seq','YlOrBr',128,'spline') .* 255);
    cmap_cool = uint8(cbrewer('seq','PuBuGn',128,'spline') .* 255);
    cmap_pval = hot(128);
    fig_all  = figure('units','normalized','outerposition',[0 0 1 1]);
    fig_ctrl = figure('units','normalized','outerposition',[0 0 1 1]);
    fig_bcnu = figure('units','normalized','outerposition',[0 0 1 1]);
    fig_diff = figure('units','normalized','outerposition',[0 0 1 1]);

    for m = 1 : nMetrics
      figure(fig_all)
        thisdata = mean(DATA(:,:,:,m),3);
        thistitle = metrics_table.shortName(m);
        thisrange = [metrics_table.rangemin(m) metrics_table.rangemax(m)];
        subplot(n1,n2,m)
        h(m) = imagesc(thisdata');
        title([thistitle '(all)'])
        set(gca,'Clim',thisrange);
        colormap(cmap_warm);colorbar
        lims(m,:) = get(gca,'Clim');
    
      figure(fig_ctrl)
        thisdata = mean(DATA(:,:,rat_table.group == "Control",m),3);
        thistitle = metrics_table.shortName(m);
        thisrange = [metrics_table.rangemin(m) metrics_table.rangemax(m)];
        subplot(n1,n2,m)
        h(m) = imagesc(thisdata');
        title([thistitle '(Control)'])
        set(gca,'Clim',thisrange);
        colormap(cmap_warm);colorbar
        lims(m,:) = get(gca,'Clim');
    
      figure(fig_bcnu)
        thisdata = mean(DATA(:,:,rat_table.group == "BCNU",m),3);
        thistitle = metrics_table.shortName(m);
        thisrange = [metrics_table.rangemin(m) metrics_table.rangemax(m)];
        subplot(n1,n2,m)
        h(m) = imagesc(thisdata');
        title([thistitle '(BCNU)'])
        set(gca,'Clim',thisrange);
        colormap(cmap_warm);colorbar
        lims(m,:) = get(gca,'Clim');
    
      figure(fig_diff)
        thisdata = mean(DATA(:,:,rat_table.group == "Control",m),3) - ...
                   mean(DATA(:,:,rat_table.group == "BCNU"   ,m),3);
        thistitle = metrics_table.shortName(m);
        thisrange = [metrics_table.rangemin(m) metrics_table.rangemax(m)];
        subplot(n1,n2,m)
        h(m) = imagesc(thisdata');
        title([thistitle '(Ctrl-BCNU)'])
        %set(gca,'Clim',thisrange);
        colormap(cmap_div);colorbar
        lims(m,:) = get(gca,'Clim');
        newlims = [abs(max(lims(m,:)))*-1 max(lims(m,:))];
        set(gca,'Clim',newlims);
        lims(m,:) = newlims;
    
    end
end


if doStats
    Mp       = zeros(nStreamlines,nDepths,nMetrics);
    Mdiff    = zeros(nStreamlines,nDepths,nMetrics);
    Meffsize = zeros(nStreamlines,nDepths,nMetrics);
    idx_ctrl = rat_table.group == "Control";
    idx_bcnu = rat_table.group == "BCNU";
    for m = 1 : nMetrics
        fprintf(1,'%d/%d : %s\n',m,nMetrics,cell2mat(metrics_table.shortName(m)));
        for sline = 1 : nStreamlines
             for depth = 1 : nDepths
                thisdata_ctrl = squeeze(DATA(sline,depth,idx_ctrl,m));
                thisdata_bcnu = squeeze(DATA(sline,depth,idx_bcnu,m));
                % via permutations
                if doPerms
                    [p,diff,effsize] = permutationTest(thisdata_ctrl,thisdata_bcnu,nperms);
                else
                    % parametric ttest
                    [h,p,ci,stats] = ttest2(thisdata_ctrl,thisdata_bcnu);
                    effsize = dcohen(thisdata_ctrl',thisdata_bcnu');
                    diff    = mean(thisdata_ctrl) - mean(thisdata_bcnu);
                end

                Mp(sline,depth,m)       = p;
                Mdiff(sline,depth,m)    = diff;
                Meffsize(sline,depth,m) = effsize;
            end
        end
    end
end

if doStats && doPlots
    fig_pvals   = figure('units','normalized','outerposition',[0 0 1 1]);
    fig_diff    = figure('units','normalized','outerposition',[0 0 1 1]);
    fig_effsize = figure('units','normalized','outerposition',[0 0 1 1]);

    figure(fig_pvals)
    for m = 1 : nMetrics
        subplot(n1,n2,m)
        if doPerms
            thistitle = cell2mat([metrics_table.shortName(m)  ' perms=' num2str(nperms)]);
        else
            thistitle = metrics_table.shortName(m);
        end
        imagesc(Mp(:,:,m)');
        set(gca,'Clim',[0 0.05]);
        colormap(cmap_pval);colorbar
        title([thistitle ' (pvalue)'])
    end

    figure(fig_diff)
    for m = 1 : nMetrics
        subplot(n1,n2,m)
        thistitle = metrics_table.shortName(m);
        imagesc(Mdiff(:,:,m)');
        %set(gca,'Clim',[0 0.05]);
        lims(m,:) = get(gca,'Clim');
        newlims = [abs(max(lims(m,:)))*-1 max(lims(m,:))];
        set(gca,'Clim',newlims);
        colormap(cmap_div);colorbar
        title([thistitle ' (difference)'])
    end

    figure(fig_effsize)
    for m = 1 : nMetrics
        subplot(n1,n2,m)
        thistitle = metrics_table.shortName(m);
        imagesc(Meffsize(:,:,m)');
        set(gca,'Clim',[-1.5 1.5]);
        colormap(cmap_div);colorbar
        title([thistitle ' (dCohen)'])
    end


    if doPerms
        suffix = 'perms';
    else
        suffix = 'param';
    end
    saveas(fig_pvals,   ['pval_' suffix '.svg'])
    saveas(fig_diff,    ['diff_' suffix '.svg'])
    saveas(fig_effsize, ['effsize_' suffix '.svg'])

end

if doStats && doPlots
    figure('units','normalized','outerposition',[0 0 1 1]);
    for m = 1 : nMetrics
        data_ctrl = DATA(:,:,idx_ctrl,m);
        data_bcnu = DATA(:,:,idx_bcnu,m);
        thistitle = cell2mat(metrics_table.shortName(m));
        thisfname = ['clusterstats_' thistitle '.png'];
        clusters = displasia_cluster_param(data_ctrl,data_bcnu,0.05,0.05,5000,4,true,thistitle);
        saveas(gcf,thisfname);
    end
end

