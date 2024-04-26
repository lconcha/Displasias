function pcluster = displasia_oli_cluster_perm_2D(groupA,groupB,...
                    ndiffperms,nclusperms,...
                    clusterformingpthreshold,...
                    clusterpthreshold,...
                    conn,...
                    metricName,...
                    doPlot,...
                    f_tck)



function cpvals = findclusterpvals(cluster_sizes,clusternulldist)
    cpvals = zeros(size(cluster_sizes));
    for c = 1 : length(cluster_sizes)
        thisclustersize = cluster_sizes(c);
        n = numel(find(clusternulldist>thisclustersize));
        cpvals(c) = n./numel(clusternulldist);
    end
end

function labels_pval = paintclusterpval(clabels,cpvals)
    labels_pval = ones(size(clabels));
    for c = 1 : length(cpvals)
       thiscpval = cpvals(c);
       labels_pval(find(clabels==c)) = thiscpval;
    end

end

groupA_name = groupA.name;
groupB_name = groupB.name;

groupA = groupA.data;
groupB = groupB.data;

nr  = size(groupA,1);
nc  = size(groupA,2);
ngA = size(groupA,3);
ngB = size(groupB,3);

groupAB = cat(3,groupA,groupB);


pAgtB   = zeros(nr,nc,nclusperms);
pAltB   = zeros(nr,nc,nclusperms);
pAdiffB = zeros(nr,nc,nclusperms);


randclustersizes = [];% unknown final size, so I cannot create in advance

fprintf(1,'  Building empirical distribution of cluster sizes that occur by chance alone with %d permutations\n',nclusperms)
textprogressbar('    Progress : ');
for perm = 1 : nclusperms
    %if mod(perm,10) == 0; fprintf(1,'%d ',round(100*(perm/nclusperms)));end
    if mod(perm,50) == 0; textprogressbar(100.*(perm./nclusperms)); end
    permutation = randperm(size(groupAB,3));
    idx1 = permutation(1:ngA);
    idx2 = permutation(ngA+1:end);
    randomSample1 = groupAB(:,:,idx1);
    randomSample2 = groupAB(:,:,idx2);
    if ndiffperms > 0
        pvals = permutation_test_2D(randomSample1,randomSample2,ndiffperms,clusterformingpthreshold,conn,false);
    else
        pvals = displasia_ttest_2D(randomSample1,randomSample2,clusterformingpthreshold,conn,false);
    end
    pAgtB  (:,:,perm) = pvals.pAgtB;
    pAltB  (:,:,perm) = pvals.pAltB;
    pAdiffB(:,:,perm) = pvals.pAdiffB;
                           
    randclustersizes   = [randclustersizes    max(pvals.clustersizes.AdiffB)];% get the largest cluster found, maybe too strict and should include all sizes found?
    
end
textprogressbar(' done.');

refclustersize = prctile(randclustersizes, 100 .* (1 - clusterpthreshold));
fprintf(1,'  INFO: Cluster size at pcluster = %1.4f is %d \n', clusterpthreshold, refclustersize );

pcluster = displasia_ttest_2D(groupA,groupB,clusterformingpthreshold,conn,false);

pcluster.cluster_pvals.AgtB    = findclusterpvals(pcluster.clustersizes.AgtB,randclustersizes);
pcluster.cluster_pvals.AltB    = findclusterpvals(pcluster.clustersizes.AltB,randclustersizes);
pcluster.cluster_pvals.AdiffB  = findclusterpvals(pcluster.clustersizes.AdiffB,randclustersizes);

pcluster.cluster_pvals_2D.AgtB    = paintclusterpval(pcluster.clusterlabels.AgtB,   pcluster.cluster_pvals.AgtB);
pcluster.cluster_pvals_2D.AltB    = paintclusterpval(pcluster.clusterlabels.AltB,   pcluster.cluster_pvals.AltB);
pcluster.cluster_pvals_2D.AdiffB  = paintclusterpval(pcluster.clusterlabels.AdiffB, pcluster.cluster_pvals.AdiffB);

pcluster.dcohen  = dcohen2D(groupA,groupB);

RESULTS.clusterstats.(metricName) = pcluster;

if doPlot
    cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
    cmap_warm = uint8(cbrewer('seq','YlOrRd',128,'spline') .* 255); 
    cmap_cool = uint8(cbrewer('seq','YlGnBu',128,'spline') .* 255); cmap_cool = flip(cmap_cool,1);
    cmap_pval = hot(128); cmap_pval = flip(cmap_pval,1);
    cmap_flag = prism(50); cmap_flag(1,:) = [1 1 1];
    cmap_purp = uint8(cbrewer('seq','BuPu',128,'spline') .* 255);

    figure('units','normalized','outerposition',[0 0 1 1]);
    cmin = prctile([groupA(:);groupB(:)],5);
    cmax = prctile([groupA(:);groupB(:)],95);
    
    mGroupA = nanmean(groupA,3);
    mGroupB = nanmean(groupB,3);
    mDiff   = mGroupA - mGroupB;
    pc_2D   = pcluster.cluster_pvals_2D.AdiffB;
    p_2D    = pcluster.pAdiffB;
    d       = pcluster.dcohen;
    prevnan = sum(isnan([cat(3,groupA,groupB)]),3);

    
    % streamlines
    subplot(3,3,1);
        thistitle = ['A:' groupA_name ', ' metricName];
        clim = [cmin cmax];
        this_cmap = cmap_cool;
        displasia_show_streamlines_with_values(f_tck,                       mGroupA, clim, thistitle, this_cmap);
    subplot(3,3,2);
        thistitle = ['B:' groupA_name ', ' metricName];
        clim = [cmin cmax];
        this_cmap = cmap_cool;
        displasia_show_streamlines_with_values(f_tck,                       mGroupB, clim, thistitle, this_cmap);
    subplot(3,3,3);
        thistitle = 'A-B';
        clim = sort([-1*prctile(mDiff(:),80) prctile(mDiff(:),80)]); % sort because sometimes values can be pos_to_negative
        this_cmap = cmap_div;
        displasia_show_streamlines_with_values(f_tck,                       mDiff,   clim, thistitle, this_cmap);
    subplot(3,3,4);
        thistitle = 'dCohen';
        clim = [-1.5 1.5];
        this_cmap = cmap_div;
        displasia_show_streamlines_with_values(f_tck,                       d,       clim, thistitle, this_cmap);
    subplot(3,3,5);
        thistitle =  ['p_{cluster} A\neqB ('   num2str(nclusperms) ' perms) | p_{cf}=' num2str(clusterformingpthreshold) ')'];
        clim = [0 clusterpthreshold];
        this_cmap = cmap_pval;
        displasia_show_streamlines_with_values(f_tck,                       pc_2D,   clim, thistitle, this_cmap);
    subplot(3,3,6);
        if ndiffperms > 0
           vertex_test = [num2str(ndiffperms) ' perms/vertex'];
        else
           vertex_test = 'ttest';
        end
        thistitle = ['p_{vertex} A\neqB (' vertex_test ')'];
        clim = [0 clusterformingpthreshold];
        this_cmap = cmap_pval;
        displasia_show_streamlines_with_values(f_tck,                       p_2D,   clim, thistitle,  this_cmap);
  

    % special panels
    subplot(3,3,7);
        thistitle = ['Distribution of random cluster sizes in ' num2str(nclusperms)  ' permutations'];
        h(7) = histogram(randclustersizes);
        title(thistitle);
        xline(refclustersize,'-r',refclustersize);
        xlabel(['Cluster size (number of vertices, ' num2str(conn) '-conn)']); ylabel('Number of occurrences');

    subplot(3,3,8)
        thistitle = 'AdiffB';
        markersize = 50;
        clim = [-1.5 1.5];
        h(8) = displasia_oli_plot_streamlines(f_tck,RESULTS,metricName,thistitle,markersize,clim,clusterpthreshold,clusterformingpthreshold);

    subplot(3,3,9)
        thistitle = 'Prevalence of invalid data (#cases)';
        %clim = [0 size(groupA,3)+size(groupB,3)];
        clim = [0 10];
        this_cmap = parula(100);
        displasia_show_streamlines_with_values(f_tck,                       prevnan, clim, thistitle, this_cmap);

    
end

end% end function
