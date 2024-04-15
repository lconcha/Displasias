function h = displasia_oli_plot_d_p(f_tck,d,p,clim,pthresh,thetitle)

% prepare colormaps
cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
cmap_pval = hot(128); cmap_pval = flip(cmap_pval,1);



fprintf(1,'Using tck: %s\n',f_tck);



if ndims(d) ~= 2
  error('values should have two dimensions')
  h = 0;
  return
end

if ndims(d) ~= ndims(p)
  error('Matrices for d and p do not have the same shape')
  h = 0;
  return
end



tck = read_mrtrix_tracks(f_tck);

mygray              = [0.5 0.5 0.5];
mylightgray         = [0.8 0.8 0.8];
this_marker_size    = 50;


%h = figure('units','normalized','outerposition',[0 0 0.5 0.5]);


for st = 1 : length(tck.data)
    thisline            = tck.data{st};
    x = thisline(:,1);
    y = thisline(:,2);
    h_lines(st)         = plot(x, y, 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
    hold on

    this_d              = d(st,:);
    this_p              = p(st,:);
    this_pbin           = this_p < pthresh;

    marker_size = 50.*abs(this_d);
    marker_color = this_d;
    h_scatter_d(st)     = scatter(x, y, marker_size, marker_color, 'filled');
    if sum(this_pbin) > 0; % si ningun punto pasa el umbral estadistico no hacemos este scatter
        x = thisline(this_pbin,1);
        y = thisline(this_pbin,2);
        marker_size = 50.*abs(this_d(this_pbin));
        marker_color = 'w';
        h_scatter_p(st)     = scatter(x ,y , marker_size, marker_color, 'LineWidth',2);
    end
end
if ~isempty(clim)
    set(gca,'Clim',clim)
end
set(gca,'colormap',cmap_div)
view(180,270)
grid off; axis off; axis equal
hold off;
set(gcf,'Color','k')
h_colorbar = colorbar(gca,'Color',mygray);
title(thetitle,'Color','w','Interpreter','none')

h = gcf;