function h = plot_tck(f_tck)


fprintf(1,'Using tck: %s\n',f_tck);



tck = read_mrtrix_tracks(f_tck);

mygray              = [0.5 0.5 0.5];
mylightgray         = [0.8 0.8 0.8];
this_marker_size    = 50;

% prepare colormaps
% cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
% cmap_warm = uint8(cbrewer('seq','YlOrBr',128,'spline') .* 255); cmap_warm = flip(cmap_warm,1);
% cmap_cool = uint8(cbrewer('seq','PuBuGn',128,'spline') .* 255); cmap_cool = flip(cmap_cool,1);
% cmap_cool = uint8(cbrewer('seq','YlGnBu',128,'spline') .* 255); cmap_cool = flip(cmap_cool,1);
% cmap_pval = hot(128); cmap_pval = flip(cmap_pval,1);




%h = figure('units','normalized','outerposition',[0 0 0.5 0.5]);


for st = 1 : length(tck.data)
    thisline            = tck.data{st};
    h_lines(st)         = plot(thisline(:,1),thisline(:,2), 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
    hold on
end
view(180,270)
grid off; axis off; axis equal
hold off;
set(gcf,'Color','k')

h = gcf;