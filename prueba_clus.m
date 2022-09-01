

nr  = 10;
nc  = 50;
ng1 = 15;
ng2 = 20;
delta = 0.25;
nperms = 100;
pthresh = 0.05;
conn = 4; % bwlabel connectivity

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


CC = bwconncomp(p<pthresh,conn);
L = labelmatrix(CC);

numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);

subplot(2,2,1)
imagesc(DIFF);colorbar
set(gca,'Clim',[-delta delta])
title('difference');
subplot(2,2,2)
imagesc(p);colorbar
title('pval');
subplot(2,2,3)
pt = p;
index = p > pthresh;
pt(index) = 1;
imagesc(pt);colorbar
set(gca,'Clim',[0 pthresh])
title('threshp');
subplot(2,2,4)
imshow(label2rgb(L,'jet','k','shuffle')); axis normal
title('clusters')