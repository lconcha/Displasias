D = '/misc/lauterbur2/lconcha/exp/displasia/structureTensor/links_to_mosaics/results';

RoiName = "ROI_S";

color_bcnu = [47 147 166];
color_ctrl = [255 255 255];

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

grps  = zeros(length(ids),1);
for i = 1 : length(ids)
    id = cell2mat(ids{i});
    fname = sprintf('%s/%s_MBP_%s_gridvectortable.csv',D,id,RoiName);
    T = readtable(fname);
    figure;
    thetitle = sprintf('%s - %s',id,RoiName);
    params = displasia_Oli_plot_coherency_energy_dot(T,thetitle)
    drawnow
    P(i) = params;


    if ~isempty(regexp(id,'ctrl', 'once'))
      grps(i)    = 0;
    else
      grps(i)    = 1;
    end

    fout = sprintf('%s/%s_STA_MBP_%s.png',D,id,RoiName);
    saveas(gcf, fout);
end

figure('Position',[895 16 743 1275]);
colordef(gcf, 'none'); % Sets black background and white text/axes

idx_ctrl = grps ==0;
idx_bcnu = grps ==1;
subplot(221);
    [h,p] = ttest([P(idx_ctrl).dot_mean], [P(idx_bcnu).dot_mean]);
    boxplot([P.dot_mean],grps,'plotstyle','traditional','BoxStyle','filled','colors',[color_ctrl;color_bcnu]./255);
    title(sprintf('dot mean (p=%1.3g)',p),'FontSize',10);
    set(gca,'XTickLabel',{'ctrl','bcnu'}); fontsize(gca, scale=2);
    set(gca,'YTick',[min(get(gca,'YTick')) max(get(gca,'YTick'))])
subplot(222);
    [h,p] = ttest([P(idx_ctrl).dot_std], [P(idx_bcnu).dot_std]);
    boxplot([P.dot_std],grps,'plotstyle','traditional','BoxStyle','filled','colors',[color_ctrl;color_bcnu]./255);
    title(sprintf('dot std (p=%1.3g)',p),'FontSize',10);
    set(gca,'XTickLabel',{'ctrl','bcnu'}); fontsize(gca, scale=2);
    set(gca,'YTick',[min(get(gca,'YTick')) max(get(gca,'YTick'))])
subplot(223);
    [h,p] = ttest([P(idx_ctrl).E_mean], [P(idx_bcnu).E_mean]);
    boxplot([P.E_mean],grps,'plotstyle','traditional','BoxStyle','filled','colors',[color_ctrl;color_bcnu]./255);
    title(sprintf('E (p=%1.3g)',p),'FontSize',10);
    set(gca,'XTickLabel',{'ctrl','bcnu'}); fontsize(gca, scale=2);
    set(gca,'YTick',[min(get(gca,'YTick')) max(get(gca,'YTick'))])
subplot(224);
    [h,p] = ttest([P(idx_ctrl).C_mean], [P(idx_bcnu).C_mean]);
    boxplot([P.C_mean],grps,'plotstyle','traditional','BoxStyle','filled','colors',[color_ctrl;color_bcnu]./255);
    title(sprintf('C (p=%1.3g)',p),'FontSize',10);
    set(gca,'XTickLabel',{'ctrl','bcnu'}); fontsize(gca, scale=2);
    set(gca,'YTick',[min(get(gca,'YTick')) max(get(gca,'YTick'))])
sgtitle(['MBP texture analysis ';RoiName],'interpreter','none');
fout = sprintf('%s/av_STA_MBP_%s.svg',D,RoiName);
set(gcf, 'InvertHardcopy', 'off')
saveas(gcf, fout);


Cprofiles = vertcat(P.Cprofile_n);
Eprofiles = vertcat(P.Eprofile_n);
Dprofiles = vertcat(P.Dprofile_n);
x = linspace(0,1,20);

figure('Position',[756 322 1684 836]);
colordef(gcf, 'none'); % Sets black background and white text/axes
fontname(gcf, 'Arial')
subplot(131)
    data = Cprofiles;
    %errorbar(x,mean(data(idx_ctrl,:))', std(data(idx_ctrl,:))','k'); hold on
    %errorbar(x,mean(data(idx_bcnu,:))', std(data(idx_bcnu,:))','r'); hold on
    h1 = shadedErrorBar(x,data(idx_ctrl,:),{@mean,@std},'lineProps',{'color',color_ctrl./255,'LineWidth',2}); hold on
    h2 = shadedErrorBar(x,data(idx_bcnu,:),{@mean,@std},'lineProps',{'color',color_bcnu./255,'LineWidth',2,'LineStyle','--'});
    view(90,90)
    title('Coherency'); set(gca,'Color','k')
    limits = [0 0.5];
    set(gca,'YLim',limits); set(gca,'XTick',[0 1],'XTickLabel',{'pial','white'},'YTick',limits)
    set([h1.edge],'Visible',false); set([h2.edge],'Visible',false)
    h1.patch.FaceAlpha = 0.5; h2.patch.FaceAlpha = 0.5;
    fontsize(gca, scale=2)
subplot(132)
    data = Eprofiles;
    h1 = shadedErrorBar(x,data(idx_ctrl,:),{@mean,@std},'lineProps',{'color',color_ctrl./255,'LineWidth',2}); hold on
    h2 = shadedErrorBar(x,data(idx_bcnu,:),{@mean,@std},'lineProps',{'color',color_bcnu./255,'LineWidth',2,'LineStyle','--'});
    view(90,90)
    title('Energy'); set(gca,'Color','k')
    limits = [0 0.5];
    set(gca,'YLim',limits); set(gca,'XTick',[],'YTick',limits)
    set([h1.edge],'Visible',false); set([h2.edge],'Visible',false)
    h1.patch.FaceAlpha = 0.5; h2.patch.FaceAlpha = 0.5;
    fontsize(gca, scale=2)
subplot(133)
    data = Dprofiles;
    h1 = shadedErrorBar(x,data(idx_ctrl,:),{@mean,@std},'lineProps',{'color',color_ctrl./255,'LineWidth',2}); hold on
    h2 = shadedErrorBar(x,data(idx_bcnu,:),{@mean,@std},'lineProps',{'color',color_bcnu./255,'LineWidth',2,'LineStyle','--'});
    view(90,90)
    title('|dot product|'); set(gca,'Color','k')
    limits = [0 1];
    set(gca,'YLim',limits); set(gca,'XTick',[],'YTick',limits)
    set([h1.edge],'Visible',false); set([h2.edge],'Visible',false);
    h1.patch.FaceAlpha = 0.5; h2.patch.FaceAlpha = 0.5;
    fontsize(gca, scale=2)
sgtitle(['MBP texture profiles ';RoiName],'interpreter','none');
set(gcf, 'InvertHardcopy', 'off')
fout = sprintf('%s/profiles_STA_MBP_%s.svg',D,RoiName);
saveas(gcf, fout);
