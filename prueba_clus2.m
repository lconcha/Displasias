

nr  = 10;
nc  = 50;
ng1 = 15;
ng2 = 20;
delta = 0.0;
nperms = 1000;
pthresh = 0.05;
conn = 4; % bwlabel connectivity
npermsclus = nperms;

A = rand(nr,nc,ng1);
B = rand(nr,nc,ng2) + delta;
AB = cat(3,A,B);


rA = reshape(A,nr*nc,ng1);
rB = reshape(B,nr*nc,ng2);

rAB = cat(2,rA,rB);


rDIFF = mean(rA,2) - mean(rB,2);
DIFF  = reshape(rDIFF,[nr nc]);

permDIFF = zeros(nr*nc,nperms);
for perm = 1 : nperms
    permutation = randperm(size(rAB,2));
    idx1 = permutation(1:ng1);
    idx2 = permutation(ng1+1:end);
    % dividing into two samples
    randomSample1 = rAB(:,idx1);
    randomSample2 = rAB(:,idx2);
    thisrandomdiff = mean(randomSample2,2) - mean(randomSample1,2);
    permDIFF(:,perm) = thisrandomdiff;
end

rp = 1 - ( (sum(abs(permDIFF) < abs(repmat(rDIFF,1,nperms)),2)) ./ nperms );
p = reshape(rp,[nr nc]);

permDIFF2D = reshape(permDIFF,[nr nc perm]);




clustersizes = zeros(npermsclus,1);
for perm = 1 : npermsclus
   CC = bwconncomp(abs(DIFF) > abs(permDIFF2D(:,:,perm)),conn);
   numPixels = cellfun(@numel,CC.PixelIdxList);
   [biggest,idx] = max(numPixels);
   if isempty(biggest); biggest=0;end
   clustersizes(perm) = biggest;
end

histogram(clustersizes);

