function pvals = displasia_ttest_2D(groupA,groupB,...
                 clusterformingpthreshold,conn,doPlot)



if size(groupA,[1 2]) ~= size(groupB,[1,2])
   error('First two dimensions of groupA and groupB must agree.')
   return
end



% parametric test for comparison
[h,pAgtB]  = ttest2(groupA,groupB,'dim',3,'tail','right');
[h,pAltB]  = ttest2(groupA,groupB,'dim',3,'tail','left');
[h,pAdiffB] = ttest2(groupA,groupB,'dim',3,'tail','both');

pvals.pAgtB      = pAgtB;
pvals.pAltB      = pAltB;
pvals.pAdiffB    = pAdiffB;
pvals.diff       = nanmean(groupA,3) - nanmean(groupB,3);


CC = bwconncomp(pAgtB < clusterformingpthreshold,conn);
pvals.clustersizes.AgtB = cellfun(@numel,CC.PixelIdxList);
L = labelmatrix(CC);
pvals.clusterlabels.AgtB = L;

CC = bwconncomp(pAltB < clusterformingpthreshold,conn);
pvals.clustersizes.AltB = cellfun(@numel,CC.PixelIdxList);
L = labelmatrix(CC);
pvals.clusterlabels.AltB = L;

CC = bwconncomp(pAdiffB < clusterformingpthreshold,conn);
pvals.clustersizes.AdiffB = cellfun(@numel,CC.PixelIdxList);
L = labelmatrix(CC);
pvals.clusterlabels.AdiffB = L;


if doPlot
    figure;
    cmin = nanmin([groupA(:);groupB(:)]);
    cmax = nanmax([groupA(:);groupB(:)]);
    subplot(3,2,1);imagesc(nanmean(groupA,3));set(gca,'Clim',[cmin cmax]);colorbar;title('A')
    subplot(3,2,2);imagesc(nanmean(groupB,3));set(gca,'Clim',[cmin cmax]);colorbar;title('B')
    subplot(3,2,3);imagesc(pAgtB);  set(gca,'Clim',[0 0.05]);colorbar;title('pAgtB')
    subplot(3,2,4);imagesc(pAltB);  set(gca,'Clim',[0 0.05]);colorbar;title('pAltB')
    subplot(3,2,5);imagesc(pAdiffB);set(gca,'Clim',[0 0.05]);colorbar;title('pAdiffB')
end


%CC                 = bwconncomp(pvals.clusterlabels.AdiffB < clusterformingpthreshold,conn);
%pvals.clustersizes = cellfun(@numel,CC.PixelIdxList);


% end
% clusters = 'blah';
% 
% return
% 
% rPvalsPerm = zeros(nr*nc,ndiffperms);
% for perm = 1 : ndiffperms
%     % dividing into two samples
%     permutation = randperm(size(rAB,2));
%     idx1 = permutation(1:ngA);
%     idx2 = permutation(ngA+1:end);
%     randomSample1 = rAB(:,idx1);
%     randomSample2 = rAB(:,idx2);
%     %[hp,pp] = ttest2(randomSample1,randomSample2,'dim',2);
%     %rPvalsPerm(:,perm) = pp;
%     
% end
% 
% 
% 
% % find cluster sizes found by chance
% pPerms = reshape(rPvalsPerm,[nr nc nperms]);
% clustersizes = [];
% for perm = 1 : nperms
%    CC = bwconncomp(pPerms(:,:,perm) < pthresh,conn);
%    numPixels = cellfun(@numel,CC.PixelIdxList);
%    clustersizes = [clustersizes numPixels];
% end
% 
% 
% 
% 
% clustersizethreshold = round(prctile(clustersizes,tpercentile));
% fprintf(1,'Maximum cluster size at %d percentile after %d permutations: %d\n',tpercentile,nperms,clustersizethreshold);
% 
% 
% % stats on actual data
% [rH,rP]    = ttest2(rA,rB,'dim',2);
% P = reshape(rP,[nr nc]);
% CC = bwconncomp(P < cfthresh,conn);
% numPixels = cellfun(@numel,CC.PixelIdxList);
% [biggest,idx] = max(numPixels);
% L = labelmatrix(CC);
% clusters = ones(size(L));
% 
% sigcluster = zeros(1,length(numPixels));
% pclusters  = zeros(1,length(numPixels));
% centroids  = zeros(length(numPixels),2);
% for lab = 1 : length(numPixels)
%     thisnumpixels = numel(find(L==lab));
%     nClustersEqualOrLargerThanThisOne = numel(find(clustersizes>=thisnumpixels));
%     pclus = nClustersEqualOrLargerThanThisOne ./ numel(clustersizes);
%     pclusters(lab) = pclus;
%     if pclus <= pthresh
%       fprintf(1,'Cluster\t%d\t%d pixels\tp=%1.4f is significant\n',lab,thisnumpixels,pclus);
%       thiscentroid = regionprops(L==lab,'centroid'); 
%       centroids(lab,:) = thiscentroid.Centroid;
%     else
%         fprintf(1,'Cluster\t%d\t%d pixels\tp=%1.4f\n',lab,thisnumpixels,pclus);
%     end
%     clusters(L==lab) = pclus;
% 
% end
% 
% 
% 
% 
% if doPlot
%     cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
%     cmap_warm = uint8(cbrewer('seq','YlOrBr',128,'spline') .* 255);
%     cmap_cool = uint8(cbrewer('seq','PuBuGn',128,'spline') .* 255);
%     cmap_pval = hot(128);
%     cmap_flag = prism(50); cmap_flag(1,:) = [1 1 1];
% 
%     subplot(2,3,1)
%     imagesc(mean(groupA,3)');
%     set(gca,'colormap',cmap_cool); colorbar;
%     title([datatitle ' | Mean of Group A'])
% 
%     subplot(2,3,2)
%     imagesc(mean(groupB,3)');
%     set(gca,'colormap',cmap_cool); colorbar;
%     title([datatitle ' | Mean of Group B'])
% 
% 
%     subplot(2,3,3)
%     DIFF = mean(groupA,3) - mean(groupB,3);
%     imagesc(DIFF');
%     lims = get(gca,'Clim');
%     newlims = [abs(max(lims))*-1 max(lims)];
%     set(gca,'colormap',cmap_div); colorbar;
%     set(gca,'Clim',newlims);
%     title('A-B')
%     subplot(2,3,4)
%     imagesc(P');
%     set(gca,'colormap',cmap_pval); colorbar;
%     set(gca,'Clim',[0 cfthresh]);colorbar
%     title('P values');
%     subplot(2,3,5)
%     histogram(clustersizes);
%     title(sprintf('Cluster threshold\n(%d permutations)',nperms))
%     vline(clustersizethreshold,'r',num2str(clustersizethreshold))
%     subplot(2,3,6)
%     imagesc(clusters' < pthresh);
%     set(gca,'colormap',cmap_flag); colorbar;
%     hold on
%     for c = 1 : length(pclusters)
%        thispclus = pclusters(c);
%        if thispclus < pthresh
%            text(centroids(c,2),centroids(c,1),num2str(pclusters(c)));
%        end
%     end
%     title('clusters')
% end
% 
