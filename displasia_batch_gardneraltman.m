

[status,hname]= unix('hostname');
hname = deblank(hname)

switch hname
    case 'mansfield'
        addpath('/home/inb/lconcha/fmrilab_software/mrtrix3/matlab');
        f_tck = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
        figuresfolder = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/results/figures';
    case 'syphon'
        addpath('/home/lconcha/software/mrtrix_matlab/matlab');
        f_tck = '/datos/syphon/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
        figuresfolder = '/datos/syphon/displasia/paraArticulo1/figures';
end


tck = read_mrtrix_tracks(f_tck);





metrics = fieldnames(RESULTS.clusterstats);
sides = {'AgtB','AltB'};

for m = 1 : length(metrics)
    metric = metrics{m}
    h_fig = figure('units','normalized','outerposition',[0 0 0.2 1]);
    for s = 1:length(sides)
        comparison = sides{s};
    
        clusterpvals2D = RESULTS.clusterstats.(metric).cluster_pvals_2D.(comparison);
        pcomparison = ['p' comparison];
        pvals          = RESULTS.clusterstats.(metric).(pcomparison);
        
        lemincluster = min(min(clusterpvals2D));
        mostSigCluster = double(clusterpvals2D == lemincluster);
        mostSigCluster(mostSigCluster==0) = NaN;
        leminp = min(min(mostSigCluster .* pvals));
        idx = find (pvals.*mostSigCluster == leminp);
        [str,depth] = ind2sub(size(pvals),idx);
        str = str(1); % take the first one only
        depth = depth(1); % take the first one only
    
        subplot(2,2,s);
        for st = 1 : length(tck.data)
            thisline              = tck.data{st};
            h_lines(st)            = plot(thisline(:,1),thisline(:,2), 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
            hold on
        end
        xyz = tck.data{str}(depth,:);
        scatter(xyz(1),xyz(2),'filled')
        view(180,270)
        grid off; axis off; axis equal
        hold off;
        
        switch(comparison)
            case('AgtB'); thistitle = 'Ctrl > BCNU';
            case('AltB'); thistitle = 'Ctrl < BCNU';
        end
        title(thistitle)
    
        subplot(2,2,s+2);
        hd = displasia_boxplot(RESULTS,metric,str,depth);
    end
      f_svg = fullfile(figuresfolder,'svg',[metric '_gardneraltman.svg'])
      f_png = fullfile(figuresfolder,'png',[metric '_gardneraltman.png']);
      set(h_fig, 'InvertHardcopy', 'off');
      saveas(h_fig,f_svg);
      saveas(h_fig,f_png);
      close(h_fig)
end




