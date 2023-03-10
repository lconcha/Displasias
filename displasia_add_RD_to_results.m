% Reviewer 2 asked for Axial and Radial diffusivities. We had only sampled
% AD and MD, so we will derive RD from the pre-populated table of results
% RD = (L2+L3) / 2;         (eq 1)
% MD = (L1 + L2 + L3) / 3;  (eq 2)
% AD = L1;                  (eq 3)
% We will assume that L2=L3 and solve for L2 in the MD equation:
% L2 = ((3*MD) - L1) / 2
% RD = (2 * L2) / 2 = L2;


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
nMetrics = size(RESULTS.data.DATA,4);
RESULTS.data.metrics{index_RD} = 'rd';
