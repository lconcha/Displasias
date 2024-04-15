function values = displasia_oli_read_txt(f_txt)


fprintf(1, '  Reading %s\n',f_txt)

fid = fopen(f_txt);

nPoints = 50;
nStreamlines = 10;
linenum = 0;
data = nan(nStreamlines,nPoints);
strnum = 0;
while true
    linenum = linenum +1;
    if linenum <2 ; fprintf(1,'  Skipping header\n');continue;end
    tline = fgets(fid);
    %fprintf(1,'linenum %d : %s\n',linenum, tline)
    if tline == -1; fprintf(1,'  End of file\n');break;end
    strline = regexprep(tline,'".*",','');
    eval(['m = ['  strline  ' ];' ])
    if length(m) < 50; continue;end
    strnum = strnum +1;
    data(strnum,:) = m;
end
fclose(fid);
values = data';