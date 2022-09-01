
addpath(genpath('/home/lconcha/software/mrtrix3/matlab'))


%% Prepare a tck with 50 streamlines.
tck150 = read_mrtrix_tracks('exampleSubject/streamlines_150_10.tck');
skipevery = 3;

data2 = tck150.data(1:skipevery:150);

tck50 = tck150;
tck50.count = length(data2);
tck50.total_count = tck50.count;
tck50.data = data2;
tck50 = rmfield(tck50,'command_history');

f_tck50 = 'exampleSubject/streamlines_50_10.tck';
write_mrtrix_tracks(tck50,f_tck50);


%% Make a matrix for visualization purposes only
nDepth = 10;
nSide  = 50;
[Side,Depth] = meshgrid(0:nSide-1,0:nDepth-1);
displasia_txt2tsf(Depth', f_tck50, 'Depth.tsf')
displasia_txt2tsf(Side', f_tck50,  'Side.tsf')



%% Generate tsfs

D1 = dir('resultados_aylin/*.txt');
D2 = dir('resultados_aylin/*/*.txt');

D{1} = D1;
D{2} = D2;


for d = 1 : length(D)
    thisD = D{d};
for i = 1 : length(thisD)
    this_txt = fullfile(thisD(i).folder,thisD(i).name);
    this_tsf = fullfile(thisD(i).folder,[thisD(i).name(1:end-4) '.tsf']);
    fprintf(1,' Converting %s to %s\n', this_txt,this_tsf);
    displasia_txt2tsf(this_txt, f_tck50, this_tsf)
end
end


