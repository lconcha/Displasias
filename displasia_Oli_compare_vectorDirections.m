

D = '/misc/lauterbur2/lconcha/exp/displasia/structureTensor/links_to_mosaics/results';

ids = {...
  "R87A_ctrl",
  "R87B_ctrl",
  "R87C_ctrl",
  "R90A_bcnu",
  "R90B_bcnu",
  "R90C_bcnu",
  "R90D_bcnu",
  "R90E_bcnu",
  "R90F_bcnu",
  "R90G_bcnu",
  "R90H_bcnu",
  "R90I_bcnu",
  "R90J_bcnu",
  "R91A_ctrl",
  "R91B_ctrl",
  "R91C_ctrl",
  "R91D_ctrl",
  "R91E_ctrl",
  "R91F_ctrl",
  "R91G_ctrl"
};

stds  = zeros(length(ids),1);
means = zeros(length(ids),1);
grps  = zeros(length(ids),1);
%P = [];  % initialize empty structure for lorentzian fits


for i = 1 : length(ids)
    % id = 'R91G_ctrl'
    id = cell2mat(ids{i});
    if ~isempty(regexp(id,'ctrl', 'once'))
      linecolor = 'k';
      grp    = 0;
    else
      linecolor = 'r';
      grp    = 1;
    end
    
    fname = fullfile(D,[id '_MBP_ROI_2_vectortable.csv']);
    S = readtable(fname);
    S2 = S;






    S2.Orientation(S.Orientation<0) = 180 - abs(S.Orientation(S.Orientation<0));
    theta    = S2.Orientation;
    count    = S2.Slice1;
    count    = count/sum(count);
    max_count=max(count);
    

    % Sort by x (optional, nice for plotting)
    x = theta;
    y = count;
    [x, order] = sort(x);
    y = y(order);
    y0 = y - min(y);
 
    % fit a Lorentzian
    params = fitLorentzian(x,y,'plot',false, 'robust', true);
    P(i) = rmfield(params,'fitObj');
    
    % 1. Calculate weighted mean
    w_avg = sum(theta .* count) / sum(count);
    % 2. Calculate variance
    % Use (data - w_avg).^2 to get squared deviations
    weighted_var = sum(count .* (theta - w_avg).^2) / sum(count);
    % 3. Standard Deviation is the square root
    w_std = sqrt(weighted_var);
    fprintf(1,'%s | weighted average = %1.2f | weighted std = %1.1f | max_count = %1.2f\n',id,w_avg,w_std, max_count)
    
    means(i) = w_avg;
    stds(i)  = w_std;
    grps(i)  = grp;
    % Convert to radians for MATLAB polar functions
    theta_rad = deg2rad(theta);
    theta_rad_n = deg2rad(theta - w_avg + 90);
    %polarplot(theta_rad_n, count, linecolor); hold on
    %y = normpdf(linspace(0,180,180),myT.mean(i),myT.std(i));
    %polarplot(deg2rad(linspace(0,180,180)),y,linecolor); hold on
    plot(theta,count,linecolor); hold on
end

myT = array2table([grps stds, means], 'VariableNames', {'group','std','mean'});
myT.group = categorical(myT.group);
myT.group = renamecats(myT.group, {'0', '1'}, {'control', 'bcnu'});
figure
subplot(1,2,1)
    boxplot(myT.mean,myT.group);
    %set(gca,'XTickLabel',{'Control','BCNU'})
    title('Subject-wise average main direction')
subplot(1,2,2)
    boxplot(myT.std,myT.group);
    %set(gca,'XTickLabel',{'Control','BCNU'})
    title('Subject-wise standard deviation of main direction')

figure;
subplot(1,2,1)
    boxplot([P.x0],grps)
    title('Peak orientation (Lorentzian distribution)')
subplot(1,2,2)
    boxplot([P.gamma],grps)
    title('FWHM (Lorentzian distribution)')


