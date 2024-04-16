function h = displasia_oli_create_subplots(f_data,figuresfolder)




% Especificar la ruta de unos tck que son los que vamos a usar como
% template
f_tck_l = 'example_files/R82B_l_perm.tck';
f_tck_r = 'example_files/R82B_r_perm.tck';

% Cargamos los datos
DATA = displasia_oli_table2matrix(f_data);

% prepare colormaps
cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
cmap_warm = uint8(cbrewer('seq','YlOrBr',128,'spline') .* 255); cmap_warm = flip(cmap_warm,1);
cmap_cool = uint8(cbrewer('seq','PuBuGn',128,'spline') .* 255); cmap_cool = flip(cmap_cool,1);
cmap_pval = hot(128); cmap_pval = flip(cmap_pval,1);

% Figuras
for hemi = 1 : 2
    h(hemi)         = figure('Renderer','painters');
    values_ctrl     = DATA.Values(:,:,DATA.index.ctrl,hemi);
    values_bcnu     = DATA.Values(:,:,DATA.index.bcnu,hemi);
    m_ctrl          = nanmean(values_ctrl, 3);
    m_bcnu          = nanmean(values_bcnu, 3);
    m_diff          = m_ctrl - m_bcnu;
    d               = dcohen2D(values_ctrl,values_bcnu);
    [h,p,ci,stats]  = ttest2(values_ctrl, values_bcnu, 'dim', 3);
    
    if hemi == 1
       f_tck = f_tck_l;
       s_hemi = 'l';
    else
       f_tck = f_tck_r;
       s_hemi = 'r';
    end

    subplot(2,3,1)
    h(1) = displasia_show_streamlines_with_values(f_tck, m_ctrl, [0 1],['Mean Ctrl ' DATA.Metric s_hemi], cmap_cool);
    subplot(2,3,2)
    h(2) = displasia_show_streamlines_with_values(f_tck, m_bcnu, [0 1],['Mean BCNU ' DATA.Metric s_hemi], cmap_cool);
    subplot(2,3,3)
    h(3) = displasia_show_streamlines_with_values(f_tck, m_diff, [-0.1 0.1],['Mean Difference ' DATA.Metric s_hemi], cmap_div);
    subplot(2,3,4)
    h(4) = displasia_show_streamlines_with_values(f_tck, d,      [-1 1],['d Cohen ' DATA.Metric s_hemi], cmap_div);
    subplot(2,3,5)
    h(5) = displasia_show_streamlines_with_values(f_tck, p,      [0 0.05],['t test (p) ' DATA.Metric s_hemi], cmap_pval);
    subplot(2,3,6)
    h(6) = displasia_show_streamlines_with_values(f_tck, p,      [0 0.0001],['t test (p) Bonf ' DATA.Metric s_hemi], cmap_pval);

    set(h(hemi),'units','normalized','outerposition',[0 0 1 1]);


     f_svg = fullfile(figuresfolder,[char(DATA.Metric) '_' s_hemi '.svg']);
     f_png = fullfile(figuresfolder,[char(DATA.Metric) '_' s_hemi '.png']);
     set(h(1), 'InvertHardcopy', 'off');
     saveas(h(1), f_svg);
     saveas(h(1), f_png);
     close(h(hemi))

   
end








