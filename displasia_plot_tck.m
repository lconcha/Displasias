function h = displasia_plot_tck(tck,coloredbyindex,permuted)


colors = jet(length(tck.data));

for s = 1 : length(tck.data)
  xyz = tck.data{s};
  if permuted
     xyz = [xyz(:,2) xyz(:,1) xyz(:,3)];
  end
  h(s) = plot3(xyz(:,1),xyz(:,2),xyz(:,3)); hold on;
  if coloredbyindex
    set(h(s),'Color',colors(s,:));
  end

end

axis equal
axis vis3d