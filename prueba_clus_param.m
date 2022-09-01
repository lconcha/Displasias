
nr  = 10;
nc  = 50;
ng1 = 15;
ng2 = 20;
delta = 0.25;
nperms = 1000;
pthresh = 0.01;
conn = 4; % bwlabel connectivity
npermsclus = nperms;
tpercentile = 99;

A = rand(nr,nc,ng1);
B = rand(nr,nc,ng2) + delta;
AB = cat(3,A,B);


rA = reshape(A,nr*nc,ng1);
rB = reshape(B,nr*nc,ng2);

rAB = cat(2,rA,rB);


rDIFF = mean(rA,2) - mean(rB,2);
DIFF  = reshape(rDIFF,[nr nc]);
[rH,rP]    = ttest2(rA,rB,'dim',2);
P = reshape(rP,[nr nc]);

rPvalsPerm = zeros(nr*nc,nperms);
for perm = 1 : nperms
    permutation = randperm(size(rAB,2));
    idx1 = permutation(1:ng1);
    idx2 = permutation(ng1+1:end);
    % dividing into two samples
    randomSample1 = rAB(:,idx1);
    randomSample2 = rAB(:,idx2);
    [hp,pp] = ttest2(randomSample1,randomSample2,'dim',2);
    rPvalsPerm(:,perm) = pp;
end


pPerms = reshape(rPvalsPerm,[nr nc nperms]);
clustersizes = zeros(nperms,1);
for perm = 1 : nperms
   CC = bwconncomp(pPerms(:,:,perm) < pthresh,conn);
   numPixels = cellfun(@numel,CC.PixelIdxList);
   [biggest,idx] = max(numPixels);
   if isempty(biggest); biggest=0;end
   clustersizes(perm) = biggest;
end

clustersizethreshold = round(prctile(clustersizes,tpercentile));
fprintf(1,'Maximum cluster size at %d percentile after %d permutations: %d\n',tpercentile,nperms,clustersizethreshold);

CC = bwconncomp(P < pthresh,conn);
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
L = labelmatrix(CC);

sigcluster = zeros(1,length(numPixels));
for lab = 1 : length(numPixels)
  if numPixels(lab) > clustersizethreshold
     fprintf(1,'Cluster %d with %d pixels is significant\n',lab,numPixels(lab));
  end
end

histogram(clustersizes);

