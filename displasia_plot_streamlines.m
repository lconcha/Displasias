
addpath('/home/inb/lconcha/fmrilab_software/mrtrix3/matlab');


f_tck = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';

tck = read_mrtrix_tracks(f_tck);


msize = 100;
mygray = [0.5 0.5 0.5];
metric = 'FA'

for s = 1 : length(tck.data)
  thisline = tck.data{s};
  thiscohen = RESULTS.clusterstats.(metric).dcohen(s,:);
  thispcluster = RESULTS.clusterstats.(metric).cluster_pvals_2D.AgtB(s,:) < 0.05;
  this_sig       = thisline;  this_sig(~thispcluster,:)       = [];
  this_sig_cohen = thiscohen;  this_sig_cohen(~thispcluster) = [];
  h_lines(s)           = plot3(thisline(:,1),thisline(:,2),thisline(:,3)+.1, '-', 'Color',mygray,'LineWidth',2); % the +1 in z is to make sure the lines are seen behind the scatterplot
  h_scatterfilled(s)   = scatter3(thisline(:,1),thisline(:,2),thisline(:,3),msize.*abs(thiscohen),thiscohen,'filled');
 set(gca,'colormap',cmap_div)


  %h_scatterpcluster(s) = scatter3(this_sig(:,1),this_sig(:,2),this_sig(:,3),msize.*2,'w', 'LineWidth',2);
  h_scatterpcluster(s) = scatter3(this_sig(:,1),this_sig(:,2),this_sig(:,3),...
                    msize.*abs(this_sig_cohen),'w', 'LineWidth',1.5);
  hold on


end

view(180,270)
grid off; axis off; axis equal
set(gcf,'Color','k')
hold off