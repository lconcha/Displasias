

tiledlayout("flow")

for r = 1 : nRats
  thisrat = DATA.Values(:,:,r,1);
  imagesc(thisrat)'
  title(DATA.IDs(r));
  nexttile
end