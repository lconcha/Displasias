function h = displasia_boxplot(RESULTS,metric,sline,depth)




metrics = fieldnames(RESULTS.clusterstats);
tm = matches(metrics, metric);

if sum(tm) > 1
    fprintf(1,'ERROR, found more than one match for metric %s\n',metric);
    h = 0;
    return
end

if sum(tm) == 0
    fprint(1,'ERROR, cannot find metric %s\n',metric);
    h = 0;
    return
end


metric_idx = find(tm==1);


data_ctrl = squeeze(RESULTS.data.DATA(sline,depth,RESULTS.data.idx_ctrl,metric_idx));
data_bcnu = squeeze(RESULTS.data.DATA(sline,depth,RESULTS.data.idx_bcnu,metric_idx));

dataToPlot = [data_ctrl;data_bcnu];
dataGroups = [ones(1,length(data_ctrl)) 2*ones(1,length(data_bcnu))]';



color_ctrl = [0.5 0.5 0.5];
color_bcnu = [1 0.5 0.5];

h.g = gardnerAltmanPlot(data_ctrl,data_bcnu, Effect="cohen");
set(gca,'XTickLabel',{'CTRL','BCNU', 'd-Cohen'});
set(h.g(1), 'MarkerEdgeColor','none','MarkerFaceColor', color_ctrl)
set(h.g(2), 'MarkerEdgeColor','none','MarkerFaceColor', color_bcnu)
set(h.g(4),'Marker','s', 'LineStyle','-', 'Color', color_ctrl)
set(h.g(5),'Marker','s', 'LineStyle','-', 'Color',color_bcnu)
title({metric,mat2str([sline,depth])})
set(h.g(3),'Color',color_ctrl)
set(gca,'YColor','k')


%h.s = swarmchart(dataGroups',dataToPlot', 20, 'filled');
h.s.XJitterWidth = 0.15;
hold on;
h.b = boxchart(dataGroups, dataToPlot, 'GroupByColor',dataGroups, 'Notch','on');
h.b(1).BoxFaceColor = color_ctrl;
h.b(2).BoxFaceColor = color_bcnu;
h.b(1).WhiskerLineColor = color_ctrl;
h.b(2).WhiskerLineColor = color_bcnu;
h.b(1).MarkerStyle = 'none';
h.b(2).MarkerStyle = 'none';
set(gca,'XTick',[1 2])
set(gca,'XTickLabel',{'CTRL','BCNU'})


hold off;
