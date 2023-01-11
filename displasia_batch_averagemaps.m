

[status,hname]= unix('hostname');
hname = deblank(hname)

switch hname
    case 'mansfield'
        addpath('/home/inb/lconcha/fmrilab_software/mrtrix3/matlab');
        f_tck = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
        figuresfolder = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/results/figures';
        f_metrics = '/misc/nyquist/lconcha/displasia_AES2021/displasia/metrics_and_ranges.txt';
        f_ranges  = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/ranges.csv';
        addpath /home/inb/lconcha/fmrilab_software/tools/matlab/toolboxes/cbrewer/cbrewer
        f_results = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/results/RESULTS.mat';


    case 'syphon'
        addpath('/home/lconcha/software/mrtrix_matlab/matlab');
        f_tck = '/datos/syphon/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
        figuresfolder = '/datos/syphon/displasia/paraArticulo1/figures';
        f_metrics = '/datos/syphon/displasia/paraArticulo1/metrics_and_ranges.txt';
        f_ranges  = '/datos/syphon/displasia/paraArticulo1/ranges.csv';
        addpath /home/lconcha/software/cbrewer
        f_results = '/datos/syphon/displasia/paraArticulo1/RESULTS.mat';


end
metrics_table = readtable(f_ranges);
tck = read_mrtrix_tracks(f_tck);
load(f_results)

mygray              = [0.5 0.5 0.5];
mylightgray         = [0.8 0.8 0.8];
this_marker_size    = 50;
metrics             = fieldnames(RESULTS.clusterstats);

% prepare colormaps
cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
cmap_warm = uint8(cbrewer('seq','YlOrBr',128,'spline') .* 255); cmap_warm = flip(cmap_warm,1);
%cmap_cool = uint8(cbrewer('seq','PuBuGn',128,'spline') .* 255); cmap_cool = flip(cmap_cool,1);
cmap_cool = uint8(cbrewer('seq','YlGnBu',128,'spline') .* 255); cmap_cool = flip(cmap_cool,1);
cmap_pval = hot(128); cmap_pval = flip(cmap_pval,1);




h_fig = figure('units','normalized','outerposition',[0 0 1 1]);
    
for m = 1 : length(metrics)
    metric = metrics{m}
    
    thisdata = squeeze(RESULTS.data.DATA(:,:,:,m));

    mean_ctrl = mean(RESULTS.data.DATA(:,:,RESULTS.data.idx_ctrl,m),3);
    mean_bcnu = mean(RESULTS.data.DATA(:,:,RESULTS.data.idx_bcnu,m),3);
    mean_all  = mean(RESULTS.data.DATA(:,:,:                    ,m),3);
    mean_diff = mean_ctrl - mean_bcnu;
    thisrange = [metrics_table.rangemin(m) metrics_table.rangemax(m)];
       
    subplot(2,2,1);
        for st = 1 : length(tck.data)
            thisline            = tck.data{st};
            h_lines(st)         = plot(thisline(:,1),thisline(:,2), 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
            thismean            = mean_ctrl(st,:);
            h_scatterfilled(st) = scatter(thisline(:,1),thisline(:,2),this_marker_size,thismean,'filled');
            hold on
        end
        set(gca,'Clim',thisrange)
        set(gca,'colormap',cmap_cool)
        view(180,270)
        grid off; axis off; axis equal
        hold off;
        set(gcf,'Color','k')
        h_colorbar = colorbar(gca,'Color',mygray);
        h_colorbar.Label.String = metrics_table.shortName(m);
        title([metric ' | Control' ],'Color','w')

     subplot(2,2,2);
        for st = 1 : length(tck.data)
            thisline            = tck.data{st};
            h_lines(st)         = plot(thisline(:,1),thisline(:,2), 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
            thismean            = mean_bcnu(st,:);
            h_scatterfilled(st) = scatter(thisline(:,1),thisline(:,2),this_marker_size,thismean,'filled');
            hold on
        end
        set(gca,'Clim',thisrange)
        set(gca,'colormap',cmap_cool)
        view(180,270)
        grid off; axis off; axis equal
        hold off;
        set(gcf,'Color','k')
        h_colorbar = colorbar(gca,'Color',mygray);
        h_colorbar.Label.String = metrics_table.shortName(m);
        title([metric ' | BCNU' ],'Color','w')

     

%       subplot(2,2,3);
%         for st = 1 : length(tck.data)
%             thisline            = tck.data{st};
%             h_lines(st)         = plot(thisline(:,1),thisline(:,2), 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
%             thismean            = mean_all(st,:);
%             h_scatterfilled(st) = scatter(thisline(:,1),thisline(:,2),this_marker_size,thismean,'filled');
%             hold on
%         end
%         set(gca,'Clim',thisrange)
%         set(gca,'colormap',cmap_cool)
%         view(180,270)
%         grid off; axis off; axis equal
%         hold off;
%         set(gcf,'Color','k')
%         h_colorbar = colorbar(gca,'Color',mygray);
%         h_colorbar.Label.String = metrics_table.shortName(m);
%         title([metric ' | All' ],'Color','w')

      subplot(2,2,4);
        for st = 1 : length(tck.data)
            thisline            = tck.data{st};
            h_lines(st)         = plot(thisline(:,1),thisline(:,2), 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
            thismean            = mean_diff(st,:);
            h_scatterfilled(st) = scatter(thisline(:,1),thisline(:,2),this_marker_size,thismean,'filled');
            hold on
        end
        lims(m,:) = get(gca,'Clim');
        newlims = [abs(max(lims(m,:)))*-1 max(lims(m,:))];
        set(gca,'Clim',newlims);
        set(gca,'colormap',cmap_div)
        view(180,270)
        grid off; axis off; axis equal
        hold off;
        set(gcf,'Color','k')
        h_colorbar = colorbar(gca,'Color',mygray);
        h_colorbar.Label.String = metrics_table.shortName(m);
        title([metric ' | Ctrl-BCNU' ],'Color','w')
  
      subplot(2,2,3)
        data_ctrl = RESULTS.data.DATA(:,:,RESULTS.data.idx_ctrl,m);
        data_bcnu = RESULTS.data.DATA(:,:,RESULTS.data.idx_bcnu,m);
        mybcnucolor = cmap_cool(length(cmap_cool)./2,:);
        nbins = 25;
        %[n,e] = histcounts(thisdata(:),nbins); % get edges from control and use them for both groups
        %[n,x] = histcounts(data_ctrl(:),e);  plot(x(2:end),n,'Color',mygray,     'LineWidth',2); hold on;
        %[n,x] = histcounts(data_bcnu(:),e);  plot(x(2:end),n,'Color',mybcnucolor,'LineWidth',2); hold off;
        xmin = prctile(thisdata(:),1); xmax = prctile(thisdata(:),99);
        hall = histogram(thisdata,'BinLimits',[xmin xmax], 'Normalization','probability'); hold on;
        e = hall.BinEdges;
        cla;
        histogram(data_ctrl, e,  'Normalization','probability','DisplayStyle', 'stairs', 'EdgeColor',mygray,'LineWidth',2); hold on
        histogram(data_bcnu, e,  'Normalization','probability','DisplayStyle', 'stairs', 'EdgeColor',mybcnucolor,'LineWidth',2); hold off
        title([metric],'Color','w')
        set(gca,'Color','k','XColor','w', 'YColor','w','box', 'off')
        legend('Control','BCNU','TextColor','w')
    
    
    
    
    f_svg = fullfile(figuresfolder,'svg',[metric '_averages.svg'])
    f_png = fullfile(figuresfolder,'png',[metric '_averages.png']);
    set(h_fig, 'InvertHardcopy', 'off');
    saveas(h_fig,f_svg);
    saveas(h_fig,f_png);
    clf;
end
close(h_fig)



