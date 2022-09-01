function displasia_txt2tsf(f_txtIN,f_tckIN,f_tsfOUT,varargin)


if nargin<3
    doAbs = false;
end

if ~isstr(f_txtIN)
    mtx = f_txtIN;
else
    mtx = load(f_txtIN);
end

if size(mtx,1) == 150
   fprintf(1,'[INFO] There are 150 lines in this matrix Skipping every three\n');
   mtx = mtx(1:3:end,:);
end

%mtx = flipdim(mtx,2); % the txt is ordered deep-to-superficial, 
                      % but the streamline vertices are ordered
                      % superf-to-deep.


%tsf = read_mrtrix_tsf(f_tckIN);
tck = read_mrtrix_tracks(f_tckIN);


ntracks_tck = length(tck.data);
%ntracks_tsf = length(tsf.data);

if ntracks_tck ~= size(mtx,1)
   fprintf(1,'ERROR: mismatch of streamlines between tck (%d) and mtx (%d)\n',ntracks_tck,size(mtx,1)); 
end




tsfmod = tck;

if isfield(tsfmod,'command_history')
    tsfmod = rmfield(tsfmod,'command_history');
end


for sline = 1 : ntracks_tck
    nVertices = length(tsfmod.data{sline}); 
    if nVertices ~= size(mtx,2)
       fprintf(1,'ERROR. Mismatch between number of columns in txt file and number of vertices (streamline %d)\n',sline); 
       return
    end
    %dataToWrite = [0:1:nVertices-1]; % index depth
    %dataToWrite = zeros(1,nVertices) + sline;
    dataToWrite = mtx(sline,:);
    tsfmod.data{sline} = dataToWrite;
    %tsfmod.data{sline}[1] = sline;
end


write_mrtrix_tsf(tsfmod,f_tsfOUT);