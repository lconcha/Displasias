function d = dcohen(sample1,sample2)



allobservations = [sample1, sample2];
observeddifference = nanmean(sample1) - nanmean(sample2);
pooledstd = sqrt(  ( (numel(sample1)-1)*std(sample1)^2 + (numel(sample2)-1)*std(sample2)^2 )  /  ( numel(allobservations)-2 )  );
d = observeddifference / pooledstd;