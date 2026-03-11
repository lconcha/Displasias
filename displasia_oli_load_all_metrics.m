% lconcha, nov 2025
% used to create pontential figures for 2025 paper on b-tensor

% Location of Oli's results:
d = '/misc/sherrington2/Olimpia/proyecto/qti+/metrics/';

% specify variables, color limits and valid ranges
         %var   %clim       %valid_range
vars  = {'FA',  [0.1 0.4],  [0 1];...
         'MD',  [0.6 1]     [0 Inf];...
         'ad',  [0.5 1.3]   [0 Inf];...
         'rd',  [0.5 0.9]   [0 Inf];...
         'Cc',  [0 0.3],    [0 1];...
         'MKa', [0.1 1.0]   [-Inf 5];...
         'MKi', [0 0.8]     [-Inf 5];...
         'uFA', [0.5 0.85],  [0 1];};

hemis = {'r','l'};



% let's find data dimensions by loading one metric
M = displasia_oli_load_txts(d,vars{1},false);
nstreamlines = size(M.ctrl,1); 
ndepths      = size(M.ctrl,2);
nhemis       = size(M.ctrl,3);
nctrl        = size(M.ctrl,4);
nbcnu        = size(M.bcnu,4);
nrats        = nctrl + nbcnu;
groupidx     = zeros(nrats,1); groupidx(1:nctrl) = 1; groupidx(nctrl+1:end) = 2;
nmetrics = length(vars);

fullM = nan(nstreamlines,ndepths,nhemis,nmetrics,nrats);

for v = 1 : length(vars)
    var = vars{v,1};
    xlim = vars{v,2};
    M = displasia_oli_load_txts(d,var,false);
   
    % just check for number of rats
    this_nCtrl                    = size(M.ctrl,4);
    this_nBcnu                    = size(M.bcnu,4);
    if this_nCtrl ~= nctrl || this_nBcnu ~= nbcnu
       error('Wrong number of rats')
       break
    end

    fullM(:,:,:,v,1:nctrl)     = M.ctrl;
    fullM(:,:,:,v,nctrl+1:end) = M.bcnu;
end

% remove bad vertices
% The valid range for FA, μFA and CC was between 0 and 1
badidx = [];
for v = 1 : length(vars)
    var = vars{v,1};
    thisM = fullM(:,:,:,v,:);
    lolim = vars{v,3}(1);
    hilim = vars{v,3}(2);
    fprintf(1,'Making sure that %s is within [%1.2g %1.2g]\n',var,lolim,hilim);
    newbadidx = find(thisM <= lolim | thisM > hilim);
    fprintf(1,'  Found %d bad vertices in %s\n',length(newbadidx),var);
    badidx = union(badidx,newbadidx);
    nbad = length(badidx);
    fprintf(1,'  Updated total of baidx is %d vertices, converted to NaN\n',nbad);
    thisM(badidx) = NaN;
    fullM(:,:,:,v,:) = thisM;
end
