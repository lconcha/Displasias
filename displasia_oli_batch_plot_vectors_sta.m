

D = '/misc/lauterbur2/lconcha/exp/displasia/structureTensor/links_to_mosaics/results';

ff = dir([D '/*gridvectortable.csv']);

for i = 1:length(ff)
  f = ff(i).name;
  thisfile = fullfile(D,f)
  thistitle = f(1:13);
  % thispng = [thisfile(1:end-4) '_tensorplot.png'];
  % hfig = displasia_oli_plot_vectors_sta(thisfile,true,false);
  % set(hfig, 'InvertHardcopy', 'off')
  % title(thistitle,'Interpreter','none')
  % saveas(hfig, thispng);
  % close(hfig)

  thispng = [thisfile(1:end-4) '_lineplot.png'];
  thissvg = [thisfile(1:end-4) '_lineplot.svg'];
  hfig = displasia_oli_plot_vectors_sta(thisfile,false,true);
  set(hfig, 'InvertHardcopy', 'off','Renderer','painters')
  %title(thistitle,'Interpreter','none')
  saveas(hfig, thissvg);
  close(hfig)
end


