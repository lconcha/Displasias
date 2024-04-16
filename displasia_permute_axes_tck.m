function tckp = displasia_permute_axes_tck(f_tck,f_tckp)



tck = read_mrtrix_tracks(f_tck);
tckp = tck;

nStreamlines = length(tck.data);

for s = 1 : nStreamlines
    xyz = tck.data{s};
    tckp.data{s} = [xyz(:,1) xyz(:,3) xyz(:,2)];
end

write_mrtrix_tracks(tckp,f_tckp) 