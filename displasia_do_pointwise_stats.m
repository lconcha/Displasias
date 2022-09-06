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
