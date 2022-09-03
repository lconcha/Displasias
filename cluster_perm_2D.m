function pcluster = cluster_perm_2D(groupA,groupB,...
                    ndiffperms,nclusperms,...
                    clusterformingpthreshold,...
                    clusterpthreshold,...
                    conn,...
                    metricName,...
                    doPlot)



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


randclustersizes = [];

fprintf(1,'Building empirical distribution of cluster sizes that occur by chance alone with %d permutations\n',nclusperms)
for perm = 1 : nclusperms
    if mod(perm,10) == 0; fprintf(1,'%d ',round(100*(perm/nclusperms)));end
    permutation = randperm(size(groupAB,3));
    idx1 = permutation(1:ngA);
    idx2 = permutation(ngA+1:end);
    randomSample1 = groupAB(:,:,idx1);
    randomSample2 = groupAB(:,:,idx2);
    pvals = permutation_test_2D(randomSample1,randomSample2,ndiffperms,clusterformingpthreshold,conn,false);
    pAgtB  (:,:,perm) = pvals.pAgtB;
    pAltB  (:,:,perm) = pvals.pAltB;
    pAdiffB(:,:,perm) = pvals.pAdiffB;
                           
    randclustersizes   = [randclustersizes    pvals.clustersizes.AgtB];
    
end
fprintf(1,'\nFinished building distribution.\n')

pcluster = permutation_test_2D(groupA,groupB,ndiffperms,clusterformingpthreshold,conn,false);

pcluster.cluster_pvals.AgtB    = findclusterpvals(pcluster.clustersizes.AgtB,randclustersizes);
pcluster.cluster_pvals.AltB    = findclusterpvals(pcluster.clustersizes.AltB,randclustersizes);
pcluster.cluster_pvals.AdiffB  = findclusterpvals(pcluster.clustersizes.AdiffB,randclustersizes);
pcluster.cluster_pvals.Student = findclusterpvals(pcluster.clustersizes.Student,randclustersizes);

pcluster.cluster_pvals_2D.AgtB    = paintclusterpval(pcluster.clusterlabels.AgtB,   pcluster.cluster_pvals.AgtB);
pcluster.cluster_pvals_2D.AltB    = paintclusterpval(pcluster.clusterlabels.AltB,   pcluster.cluster_pvals.AltB);
pcluster.cluster_pvals_2D.AdiffB  = paintclusterpval(pcluster.clusterlabels.AdiffB, pcluster.cluster_pvals.AdiffB);
pcluster.cluster_pvals_2D.Student = paintclusterpval(pcluster.clusterlabels.Student,pcluster.cluster_pvals.Student);

if doPlot
    cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
    cmap_warm = uint8(cbrewer('seq','YlOrBr',128,'spline') .* 255); 
    cmap_cool = uint8(cbrewer('seq','PuBuGn',128,'spline') .* 255); cmap_cool = flip(cmap_cool,1);
    cmap_pval = hot(128); cmap_pval = flip(cmap_pval,1);
    cmap_flag = prism(50); cmap_flag(1,:) = [1 1 1];

    figure('units','normalized','outerposition',[0 0 1 1]);
    cmin = min([groupA(:);groupB(:)]);
    cmax = max([groupA(:);groupB(:)]);
    subplot(3,3,1);imagesc(mean(groupA,3)');set(gca,'Clim',[cmin cmax]);colorbar;title(['A:' groupA_name ', ' metricName]); set(gca,'colormap',cmap_cool);
    subplot(3,3,2);imagesc(mean(groupB,3)');set(gca,'Clim',[cmin cmax]);colorbar;title(['B:' groupB_name ', ' metricName]); set(gca,'colormap',cmap_cool);
    subplot(3,3,3);imagesc(pcluster.diff')';colorbar;title('A-B'); set(gca,'colormap',cmap_div);
    lims = get(gca,'Clim');
        newlims = [-abs(max(lims)) max(lims)];
        set(gca,'Clim',newlims);
    subplot(3,3,4);imagesc(pcluster.pAgtB');  set(gca,'Clim',[0 0.05]);colorbar;title(['pAgtB ('   num2str(ndiffperms) ' perms)']); set(gca,'colormap',cmap_pval);
    subplot(3,3,5);imagesc(pcluster.pAltB');  set(gca,'Clim',[0 0.05]);colorbar;title(['pAltB ('   num2str(ndiffperms) ' perms)']); set(gca,'colormap',cmap_pval);
    subplot(3,3,6);imagesc(pcluster.pAdiffB');set(gca,'Clim',[0 0.05]);colorbar;title(['pAdiffB (' num2str(ndiffperms) ' perms)']); set(gca,'colormap',cmap_pval);
    subplot(3,3,7);imagesc(pcluster.cluster_pvals_2D.AgtB');set(gca,'Clim',[0 0.05]);colorbar;title(['pcluster AgtB ('   num2str(nclusperms) ' perms)']); set(gca,'colormap',cmap_pval);
    subplot(3,3,8);imagesc(pcluster.cluster_pvals_2D.AltB');set(gca,'Clim',[0 0.05]);colorbar;title(['pcluster AltB ('   num2str(nclusperms) ' perms)']); set(gca,'colormap',cmap_pval);
    subplot(3,3,9);imagesc(pcluster.Student');      set(gca,'Clim',[0 0.05]);colorbar;title('Student t'); set(gca,'colormap',cmap_pval);
end


end