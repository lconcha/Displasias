% lconcha, Nov 2025


figuresdir = '/misc/lauterbur2/lconcha/exp/displasia/olimpia/figures_lconcha/';

displasia_oli_load_all_metrics


for varn = 1 : length(vars)

    h = displasia_oli_plot_average_oneMetric(fullM,vars,varn,hemis,groupidx,figuresdir);
    clf
end