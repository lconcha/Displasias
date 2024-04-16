% preparamos nuestra sesion
addpath /home/inb/soporte/lanirem_software/mrtrix_3.0.4/matlab
addpath(genpath('/misc/mansfield/lconcha/software/Displasias'))


results_folder = '/misc/sherrington2/Olimpia/proyecto/qti+/csv_metrics_p';
figuresfolder  = '/misc/mansfield/lconcha/exp/displasia/oli_pruebas/';

D = dir([results_folder '/*.csv']);

for f = 1 : length(D)
    f_csv = fullfile(results_folder, D(f).name);
    h = displasia_oli_create_subplots(f_csv,figuresfolder);

end





% % Especificar la ruta de unos tck que son los que vamos a usar como
% % template
% f_tck = 'example_files/streamlines_50_10.tck';
% 
% rango_color = [0 0.4];
% 
% 
% %% Elegantes, leyendo todos los valres
% carpeta_datos = '/misc/sherrington2/Olimpia/proyecto/qti+/metrics/FA/';
% D_ctrl = dir([carpeta_datos 'ctrl_*_vn_l_*.txt']);
% D_bcnu = dir([carpeta_datos 'bcnu_*_vn_l_*.txt']);
% 
% nStreamlines = 50;
% nDepths      = 10;
% n_ctrl       = length(D_ctrl);
% n_bcnu       = length(D_bcnu);
% 
% val_ctrl = zeros(nStreamlines,nDepths,n_ctrl);
% val_bcnu = zeros(nStreamlines,nDepths,n_bcnu);
% 
% for r = 1 : n_ctrl
%   f_datos = fullfile(carpeta_datos,D_ctrl(r).name);
%   this_val = readmatrix(f_datos,'Range',[2 1]);
%   val_ctrl(:,:,r) = this_val;
% end
% 
% for r = 1 : n_bcnu
%   f_datos = fullfile(carpeta_datos,D_bcnu(r).name);
%   this_val = readmatrix(f_datos,'Range',[2 1]);
%   val_bcnu(:,:,r) = this_val;
% end
% 
% 
% % Medias de cada grupo
% mean_ctrl = mean(val_ctrl,3,"omitnan");
% mean_bcnu = mean(val_bcnu,3,"omitnan");
% h_mc = displasia_show_streamlines_with_values(f_tck,mean_ctrl,rango_color,'media de los controles');
% figure;
% h_mb = displasia_show_streamlines_with_values(f_tck,mean_bcnu,rango_color,'media de los BCNU');
% 
% % Diferencia de medias
% cmap_div  = uint8(cbrewer('div','PuOr',128, 'spline') .* 255);
% h_diff = displasia_show_streamlines_with_values(f_tck,mean_ctrl - mean_bcnu,[-0.1 0.1],'ctrl - bcnu',cmap_div);
% 
% %dCohen
% d = dcohen2D(val_ctrl,val_bcnu);
% h_diff = displasia_show_streamlines_with_values(f_tck, d ,[-1 1],'d Cohen',cmap_div);
% 
% 
% % p simulada
% p = rand(nStreamlines,nDepths);
% cmap_warm = uint8(cbrewer('seq','YlOrBr',128,'spline') .* 255); cmap_warm = flip(cmap_warm,1);
% h_diff = displasia_show_streamlines_with_values(f_tck, p ,[0 0.05],'p',cmap_warm);
% 
% 
% % figura elegante
% h_diff = displasia_show_streamlines_with_values(f_tck, d ,[-1 1],'d Cohen',cmap_div);
% hold on



