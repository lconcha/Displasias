function params = displasia_plot_coherency_energy_dot(T,thetitle)

if isempty(thetitle)
    thetitle = ""; 
end

co_lims = [0 1];
en_lims = [0 0.5];

orients = T.Orientation;
dot_values = cosd(orients -  repmat(0,size(orients)));

% T2 = T;
% T2.Orientation(T.Orientation<0) = 180 - abs(T.Orientation(T.Orientation<0));
% theta    = abs(orients);
% dot_values = cosd(theta  - repmat(90,size(theta)));
% radiality = 1 - theta/90;
% theta2 = T.Orientation;


energy_thr = 0.025;
energy_mask = T.Energy > energy_thr;
mask = energy_mask;

X = T.X(mask,:);
Y = T.Y(mask,:);
C = T.Coherency(mask,:);
E = T.Energy(mask,:);
dot_values = dot_values(mask);
%radiality = radiality(mask);


clf
set(gcf,'Position',[1625 45 473 1369])
subplot(3,3,1)
scatter(X,Y,10,C,'filled')
    set(gca,'YLim',[min(T.Y) max(T.Y)]);
    set(gca,'XLim',[min(T.X) max(T.X)])
    view(0,-90)
    colorbar; axis off; title('Coherency')
    set(gca,'CLim',co_lims)
subplot(3,3,3)
    histogram(C,50); title('Coherency')
    set(gca,'XLim',co_lims)
subplot(3,3,4)
scatter(X,Y,10,E,'filled'); title('Energy')
    set(gca,'YLim',[min(T.Y) max(T.Y)]);
    set(gca,'XLim',[min(T.X) max(T.X)])
    view(0,-90)
    colorbar; axis off
    set(gca,'CLim',en_lims)
subplot(3,3,6)
    histogram(E,50); title('Energy')
    set(gca,'XLim',en_lims)
subplot(3,3,7)
    scatter(X,Y,10,dot_values,'filled'); title('|Dot values|')
    set(gca,'YLim',[min(T.Y) max(T.Y)]);
    set(gca,'XLim',[min(T.X) max(T.X)])
    view(0,-90)
    colorbar; axis off
    set(gca,'CLim',[0 1])
subplot(3,3,9)
    histogram(abs(dot_values),50); title('|Dot values|')
    set(gca,'XLim',[0 1])
    % histogram(radiality,50)

params.dot_mean = mean(dot_values);
params.dot_median = median(dot_values);
params.dot_std  = std(dot_values);
params.E_mean   = mean(E);
params.E_std    = std(E);
params.C_mean   = mean(C);
params.C_std    = std(C);



uY = unique(Y);
Cprofile = nan(length(uY),1);
Cprofilestd = Cprofile;
Eprofile = nan(length(uY),1);
Eprofilestd = Eprofile;
Dprofile = nan(length(uY),1);
Dprofilestd = Dprofile;
for i = 1 : length(uY)
  thisy = uY(i);
  idx   = Y==thisy;
  Cprofile(i) = nanmean(C(idx)); Cprofilestd(i) = nanstd(C(idx)); 
  Eprofile(i) = nanmean(E(idx)); Eprofilestd(i) = nanstd(E(idx)); 
  Dprofile(i) = nanmean(abs(dot_values(idx)));  Dprofilestd(i) = nanstd(abs(dot_values(idx))); 
  % Dprofile(i) = nanmean(radiality(idx)); Dprofilestd(i) = nanstd(radiality(idx));
end

y20 = linspace(min(uY),max(uY),20);

Cprofile_n = interp1(uY,Cprofile,y20);
Eprofile_n = interp1(uY,Eprofile,y20);
Dprofile_n = interp1(uY,Dprofile,y20);


subplot(3,3,2)
    % plot(Cprofile,uY,'r');  view(0,-90); set(gca, 'XLim',co_lims); hold on;
    % plot(Cprofile + Cprofilestd,uY,'k');  view(0,-90); set(gca, 'XLim',co_lims); hold on;
    % plot(Cprofile - Cprofilestd,uY,'k');  view(0,-90); set(gca, 'XLim',co_lims); hold on;
    plot(Cprofile_n,y20,'r'); view(0,-90); set(gca, 'XLim',co_lims); yticks([]);
subplot(3,3,5)
    % plot(Eprofile,uY,'r');  view(0,-90); set(gca, 'XLim',co_lims); hold on;
    % plot(Eprofile + Eprofilestd,uY,'k');  view(0,-90); set(gca, 'XLim',en_lims); hold on;
    % plot(Eprofile - Eprofilestd,uY,'k');  view(0,-90); set(gca, 'XLim',en_lims); hold on;
    plot(Eprofile_n,y20,'r'); view(0,-90); set(gca, 'XLim',en_lims); yticks([]);
subplot(3,3,8)
    % plot(Dprofile,uY,'r');  view(0,-90); set(gca, 'XLim',co_lims); hold on;
    % plot(Dprofile + Dprofilestd,uY,'k');  view(0,-90); set(gca, 'XLim',[0 1]); hold on;
    % plot(Dprofile - Dprofilestd,uY,'k');  view(0,-90); set(gca, 'XLim',[0 1]); hold on;
    plot(Dprofile_n,y20,'r'); view(0,-90); set(gca, 'XLim',[0 1]); yticks([]);


params.Cprofile_n = Cprofile_n;
params.Eprofile_n = Eprofile_n;
params.Dprofile_n = Dprofile_n;

sgtitle(thetitle,'interpreter','none');
    
