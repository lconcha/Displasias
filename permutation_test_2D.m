function pvals = permutation_test_2D(groupA,groupB,ndiffperms,...
                 clusterformingpthreshold,conn,doPlot)



if size(groupA,[1 2]) ~= size(groupB,[1,2])
   error('First two dimensions of groupA and groupB must agree.')
   return
end



% parametric test for comparison
[h,p] = ttest2(groupA,groupB,'dim',3);




nr  = size(groupA,1);
nc  = size(groupA,2);
ngA = size(groupA,3);
ngB = size(groupB,3);

groupAB = cat(3,groupA,groupB);

rA = reshape(groupA,nr*nc,ngA);
rB = reshape(groupB,nr*nc,ngB);
rAB = cat(2,rA,rB);


truediff = nanmean(groupA,3) - nanmean(groupB,3);

allpermdiff     = zeros(nr,nc,ndiffperms);
alldiffdeltabin = zeros(nr,nc,ndiffperms);
for perm = 1 : ndiffperms
    permutation = randperm(size(groupAB,3));
    idx1 = permutation(1:ngA);
    idx2 = permutation(ngA+1:end);
    randomSample1 = groupAB(:,:,idx1);
    randomSample2 = groupAB(:,:,idx2);
    thispermdiff = nanmean(randomSample1,3) - nanmean(randomSample2,3);
    allpermdiff(:,:,perm) = thispermdiff;
    thisdiffdeltabin = truediff > thispermdiff;
    alldiffdeltabin(:,:,perm) = thisdiffdeltabin;
end

AgtB    =     (repmat(truediff,1,1,ndiffperms)) >     allpermdiff ;
AltB    =     (repmat(truediff,1,1,ndiffperms)) <     allpermdiff ;
AdiffB  =  abs(repmat(truediff,1,1,ndiffperms)) > abs(allpermdiff) ;

pAgtB   = 1- mean(AgtB,  3);
pAltB   = 1- mean(AltB,  3);
pAdiffB = 1- mean(AdiffB,3);


pvals.pAgtB      = pAgtB;
pvals.pAltB      = pAltB;
pvals.pAdiffB    = pAdiffB;
pvals.Student    = p;
pvals.ndiffperms = ndiffperms;
pvals.diff       = truediff;


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

CC = bwconncomp(p < clusterformingpthreshold,conn);
pvals.clustersizes.Student = cellfun(@numel,CC.PixelIdxList);
L = labelmatrix(CC);
pvals.clusterlabels.Student = L;


if doPlot
    figure;
    cmin = nanmin([groupA(:);groupB(:)]);
    cmax = nanmax([groupA(:);groupB(:)]);
    subplot(3,3,1);imagesc(nanmean(groupA,3));set(gca,'Clim',[cmin cmax]);colorbar;title('A')
    subplot(3,3,2);imagesc(nanmean(groupB,3));set(gca,'Clim',[cmin cmax]);colorbar;title('B')
    subplot(3,3,3);imagesc(truediff);set(gca,'Clim',[-cmax.*0.2 cmax.*0.2]);colorbar;title('A-B')
    subplot(3,3,4);imagesc(pAgtB);  set(gca,'Clim',[0 0.05]);colorbar;title('pAgtB')
    subplot(3,3,5);imagesc(pAltB);  set(gca,'Clim',[0 0.05]);colorbar;title('pAltB')
    subplot(3,3,6);imagesc(pAdiffB);set(gca,'Clim',[0 0.05]);colorbar;title('pAdiffB')
    subplot(3,3,7);imagesc(p);      set(gca,'Clim',[0 0.05]);colorbar;title('Student t')
end


