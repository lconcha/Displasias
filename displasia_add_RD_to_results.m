% Reviewer 2 asked for Axial and Radial diffusivities. We had only sampled
% AD and MD, so we will derive RD from the pre-populated table of results
% RD = (L2+L3) / 2;         (eq 1)
% MD = (L1 + L2 + L3) / 3;  (eq 2)
% AD = L1;                  (eq 3)
% We will assume that L2=L3 and solve for L2 in the MD equation:
% L2 = ((3*MD) - L1) / 2
% RD = (2 * L2) / 2 = L2;

cd('/misc/mansfield/lconcha/exp/displasia/paraArticulo1/results')
load RESULTS

% check if you have already done this by taking a peek into :
RESULTS.data.metrics
% and if you see 'rd' then you can go do something else.

% The indices for the needed metrics in RESULTS.data.DATA are as follows:
index_AD = 1;  % ad.txt
index_MD = 10; % md.txt

% Calculate RD
MD = RESULTS.data.DATA(:,:,:,index_MD);
AD = RESULTS.data.DATA(:,:,:,index_AD);
RD = ((3*MD) - AD) ./ 2;

% inject RD into the RESULTS
nMetrics = size(RESULTS.data.DATA,4);
index_RD = nMetrics + 1;
RESULTS.data.DATA(:,:,:,index_RD) = RD;
RESULTS.data.metrics{index_RD} = 'rd';

% put the data outside the structure so we can use the next scripts
DATA = RESULTS.data.DATA;
rat_table = RESULTS.data.rat_table;
nMetrics = size(RESULTS.data.DATA,4);

