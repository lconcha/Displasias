

f_tck = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/streamlines_50_10_voxelcoords.tck';
%f_tck = '/datos/syphon/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';

f_fa = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/mrds_example_DTInolin_FA.nii';
FA   = niftiread(f_fa);
faback = transpose(FA(:,:,15));

snapsdir = '/misc/mansfield/lconcha/exp/displasia/paraArticulo1/exampleSubject/snaps';
f_avi = fullfile(snapsdir,'streamlines_animation.avi');
vidObj = VideoWriter(f_avi);
vidObj.FrameRate = 200;
open(vidObj)

tck = read_mrtrix_tracks(f_tck);

f = figure;

%set(gca,'XLim',[-7 2], 'YLim',[-1 6])
pcolor(faback)
shading interp
colormap(gray)
axis off;
axis image;
set(gca,'XLim',[20 80], 'YLim',[20 75])
set(gca,'CLim',[0 1])
drawnow;
hold on



%M = struct('cdata',[],'colormap',[]);

%framenum = 0;

offset = 1.5;

color_salmon = [252 153 98] ./ 255;
color_orange = [254 99 72] ./ 255;
color_oil   = [55 132 122] ./ 255;
color_cyan  = [20 200 200] ./ 255;

color_pial = color_salmon;
color_wm   = color_salmon;
color_stream = color_cyan;


line_pial   = animatedline('Color',color_pial,'LineWidth',2);
line_wm     = animatedline('Color',color_wm,  'LineWidth',2);

% pial
for s = 1 : length(tck.data)
  this_streamline = tck.data{s} +offset;
  this_xyz = this_streamline(1,:);
  %scatter(this_xyz(1),this_xyz(2),this_xyz(3),color_pial,'filled')
  addpoints(line_pial,this_xyz(1),this_xyz(2),this_xyz(3));
  drawnow;
  %framenum = framenum +1; M(framenum) = getframe;
  writeVideo(vidObj,getframe(gca));
end

% wm
for s = 1 : length(tck.data)
  this_streamline = tck.data{s} +offset;
  this_xyz = this_streamline(end,:);
  %scatter(this_xyz(1),this_xyz(2),this_xyz(3),color_wm,'filled')
  addpoints(line_wm,this_xyz(1),this_xyz(2),this_xyz(3));
  drawnow
  %framenum = framenum +1; M(framenum) = getframe;
    writeVideo(vidObj,getframe(gca));


end


% depths
for s = 1 : length(tck.data)
  this_streamline = tck.data{s} + offset;
  line_stream = animatedline('Color',color_stream,  'LineWidth',1,'Marker','o','MarkerSize',2,'MarkerFaceColor',color_stream);
  for p = 1 : length(this_streamline)
      this_xyz = this_streamline(p,:);
      addpoints(line_stream,this_xyz(1),this_xyz(2),this_xyz(3));
      %scatter(this_xyz(1),this_xyz(2),5,color_stream,'filled')
      drawnow;
      %framenum = framenum +1; M(framenum) = getframe;
        writeVideo(vidObj,getframe(gca));


  end
end


    close(vidObj);
