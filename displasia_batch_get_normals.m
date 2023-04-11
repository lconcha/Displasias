% script to get the dot product to streamline and image plane for all rats
% Hey, do not forget to load RESULTS.mat first!!!
% March 30, 2023.
% lconcha



[status,hname]= unix('hostname');
hname = deblank(hname);

switch hname
    case 'mansfield'
         error('not implemented for mansfield yet.')

    case 'syphon'
        addpath('/home/lconcha/software/mrtrix_matlab/matlab');
        addpath(genpath('/home/lconcha/software/dicm2nii-master'))
        addpath /home/lconcha/software/Displasias/
        addpath(genpath('/home/lconcha/software/matGeom'))
        addpath('/home/lconcha/software/cbrewer');



        nRats = length(RESULTS.data.rat_table.rat_id);

        all_dot_par2streamline = nan(50,10,nRats);
        all_dot_perp2plane     = nan(50,10,nRats);
        for n = 1 : nRats
          thisRat = RESULTS.data.rat_table.rat_id{n};
          f_tck = ['/datos/syphon/displasia/paraArticulo1/para_tckfixelsample/tck50/' thisRat '.tck'];
          mrds_basename = ['/datos/syphon/displasia/paraArticulo1/para_tckfixelsample/' thisRat '_mrds_MRDS_Diff_BIC'];

          f_PDD         = [mrds_basename, '_PDDs_CARTESIAN.nii.gz'];
          f_nComp       = [mrds_basename, '_NUM_COMP.nii.gz'];
          ff_values_in  = {[mrds_basename, '_FA.nii.gz']};

          f_prefix      =  ['/datos/syphon/displasia/paraArticulo1/para_tckfixelsample/results/' thisRat];

          %%%%%%%%
          VALUES = displasia_tckfixelsample(f_tck, f_PDD, f_nComp, ff_values_in, f_prefix);
          %%%%%%%%

          all_dot_par2streamline(:,:,n) = VALUES.dot_parallel2streamline;
          all_dot_perp2plane(:,:,n)     = VALUES.dot_perp2slicenormal;
        end
end


% replace placeholders for dot_perp2plane (needed for creation of tsf files) for NaNs, so we
% can compute the averages correctly.

idx_placehoders = find(all_dot_perp2plane == -999);
all_dot_perp2plane(idx_placehoders) = NaN;

av_dot_par2streamline_CTRL = mean(all_dot_par2streamline(:,:,RESULTS.data.idx_ctrl), 3, 'omitnan');
av_dot_par2streamline_BCNU = mean(all_dot_par2streamline(:,:,RESULTS.data.idx_bcnu), 3, 'omitnan');
av_dot_perp2plane_CTRL     = mean(all_dot_perp2plane    (:,:,RESULTS.data.idx_ctrl), 3, 'omitnan');
av_dot_perp2plane_BCNU     = mean(all_dot_perp2plane    (:,:,RESULTS.data.idx_bcnu), 3, 'omitnan');

figure;
subplot(2,2,1)
imagesc(av_dot_par2streamline_CTRL'); colorbar; set(gca,'CLim',[0 1]); title('|dot(Tpar, streamline)| CTRL'); xlabel('streamlines'); ylabel('depth');
subplot(2,2,2)
imagesc(av_dot_par2streamline_BCNU'); colorbar; set(gca,'CLim',[0 1]); title('|dot(Tpar, streamline)| BCNU'); xlabel('streamlines'); ylabel('depth');
subplot(2,2,3)
imagesc(av_dot_perp2plane_CTRL'); colorbar; set(gca,'CLim',[0 1]); title('|dot(Tperp, planeNormal)| CTRL'); xlabel('streamlines'); ylabel('depth');
subplot(2,2,4)
imagesc(av_dot_perp2plane_BCNU'); colorbar; set(gca,'CLim',[0 1]); title('|dot(Tperp, planeNormal)| BCNU'); xlabel('streamlines'); ylabel('depth');


figure;
my_cmap = parula(100);
f_tck = '/datos/syphon/displasia/paraArticulo1/exampleSubject/streamlines_50_10.tck';
subplot(221); displasia_show_streamlines_with_values(f_tck, av_dot_par2streamline_CTRL,  [0 1],'|dot(Tpar, streamline)| CTRL',   my_cmap)
subplot(222); displasia_show_streamlines_with_values(f_tck, av_dot_par2streamline_BCNU, [0 1],'|dot(Tpar, streamline)| BCNU',    my_cmap)
subplot(223); displasia_show_streamlines_with_values(f_tck, av_dot_perp2plane_CTRL,      [0 1],'|dot(Tperp, planeNormal)| CTRL', my_cmap)
subplot(224); displasia_show_streamlines_with_values(f_tck, av_dot_perp2plane_BCNU,      [0 1],'|dot(Tperp, planeNormal)| BCNU', my_cmap)