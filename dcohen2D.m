function d = dcohen2D(A,B)


meanA = nanmean(A,3);
meanB = nanmean(B,3);

stdA = nanstd(A,1,3);
stdB = nanstd(B,1,3);

AB = cat(3,A,B);
meanAB = nanmean(AB,3);
stdAB  = nanstd(AB,1,3);


observeddifference = meanA - meanB;


d = observeddifference ./ stdAB;
