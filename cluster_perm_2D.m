function pcluster = cluster_perm_2D(groupA,groupB,...
                    ndiffperms,nclusperms,...
                    clusterformingpthreshold,...
                    conn,...
                    doPlot)



function cpvals = findclusterpvals(cluster_sizes,clusternulldist)
    cpvals = zeros(size(cluster_sizes));
    for c = 1 : length(cluster_sizes)
        thisclustersize = cluster_sizes(c);
        n = numel(find(clusternulldist>thisclustersize));
        cpvals(c) = n./numel(clusternulldist);
    end
end


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
    fprintf(1,'%d ',round(100*(perm/nclusperms)))
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

if doPlot
  fprintf(1, 'plots not coded yet\n')
end


end