function DATA = displasia_oli_table2matrix(f_csv)
%f_csv = 'example_files/uFAp_long.csv';

T = readtable(f_csv);
T = convertvars(T,@iscellstr,"categorical");


nGroups = length(unique(T.group));
if nGroups ~= 2
    fprintf     (1,'ERROR. Cannot have more than two groups.')
end


nMetrics = length(unique(T.metric));
nStreamlines    = 50;
nPoints         = 10;
unique_rats     = unique(T.ID);
hemispheres     = ["l" "r"];
nHemispheres    = length(hemispheres);


nRats           = length(unique_rats);
nRats_bcnu      = length(unique(T.ID(T.group=="bcnu")));
nRats_ctrl      = length(unique(T.ID(T.group=="ctrl")));

fprintf('INFO: There are %d rats in total (%d ctrl and %d BCNU)\n',nRats,nRats_ctrl,nRats_bcnu);

if nMetrics ~= 1
  fprintf       (1,'ERROR. Cannot work on more than one metric at a time.\n')
  DATA          = NaN;
  return;
end

VALUES          = nan(nStreamlines,nPoints,nRats,nHemispheres);
IDs             = categorical;
GROUPS          = categorical;

for r = 1 : nRats
  thisRatID     = unique_rats(r);
  this_grp      = unique(T.group(T.ID==thisRatID));
  if length(this_grp) > 1
    fprintf     (1,'ERROR. Rat %s has more than one group assignment\n',thisRatID);
    DATA        = NaN;
    return
  end
  fprintf       (1,'INFO: Reading data for rat %s (%s)... ',thisRatID,this_grp);
  IDs(r)        = thisRatID;
  GROUPS(r)     = this_grp;
  
  for h = 1 : 2
      this_hemi         = hemispheres(h);
      this_rat_values   = T(T.ID==thisRatID & T.hem==this_hemi,:);
      i                 = this_rat_values.stream;
      j                 = this_rat_values.point;
      v                 = this_rat_values.values;
      fprintf           (1,'  %s_hemi (%d values)',this_hemi, length(v));
      this_matrix       = nan(nStreamlines,nPoints);
      IND               = sub2ind(size(this_matrix),i,j);
      this_matrix(IND)  = v;
      VALUES(:,:,r,h)   = this_matrix;
  end
  fprintf(1,'.\n');
end

index_ctrl      = GROUPS == "ctrl";
index_bcnu      = GROUPS == "bcnu";


DATA.IDs         = IDs;
DATA.Groups      = GROUPS;
DATA.index.ctrl  = index_ctrl;
DATA.index.bcnu  = index_bcnu;
DATA.Values      = VALUES;
DATA.Hemispheres = hemispheres;
DATA.Metric      = unique(T.metric);