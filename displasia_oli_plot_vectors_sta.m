function hfig = displasia_oli_plot_vectors_sta(f,doEllipsoid,doLines)

%f = '/misc/lauterbur2/lconcha/exp/displasia/structureTensor/links_to_mosaics/results/R87A_ctrl_MBP_ROI_M_gridvectortable.csv';

%doEllipsoid = false;
%doLines     = true;

T = readtable(f);

x  = T.X;
y  = T.Y;
dx = T.DX;
dy = T.DY;
C  = T.Coherency;
E  = T.Energy;

scalemetric   = C;
C(E<0.01) = 0.01; % threshold by Energy






%load('lipari')
%cm = lipari;
cm = slanCM('afmhot');
cm(1,:) = [0 0 0];
cminv = flipdim(cm,1);

% figure('Position',[2088 46 267 1092]);
% colordef(gcf, 'none'); % Sets black background and white text/axes
% scatter(x,y,50,scalemetric,'filled','square'); colormap(cm);colorbar
% view(0,-90)
% set(gca,'XLim',[min(x) max(x)])
% set(gca,'YLim',[min(y) max(y)])
% set(gca,'CLim',[0 1])
% axis off

hfig = figure('Position',[2088 46 267 1092]);
colordef(gcf, 'none'); % Sets black background and white text/axes
fprintf(1,'%d points\n',length(x))

for k = 1:length(x)
    x0 = x(k);
    y0 = y(k);
    v = [dx(k) dy(k)];
    vn = normalize(v,"norm");
    theta = atan2(vn(2), vn(1));      % radians

    
    
    cidx = round(scalemetric(k).*size(cm,1)) +1;
    thiscolor  = cm(cidx,:);
    if E(k) > 0.01
        if doEllipsoid
            constantscale = 10;
            ellipsemajor = constantscale;
            ellipseminor = ellipsemajor .* (1-scalemetric(k));
            [ex,ey,eh] = ellipse2D(x0,y0,ellipsemajor,ellipseminor,theta,100,...
                'DoPlot',true,'FaceColor',thiscolor);
            set(eh,'EdgeAlpha',0);
            %thisalpha = 0.3 + scalemetric(k); if thisalpha>1; thisalpha=0;end 
            thisalpha = 1;
            set(eh,'FaceAlpha',thisalpha)
            hold on;
        end
        if doLines
            constantscale = 15;
            % S = constantscale .* scalemetric(k);
            S = 10;
            x1 = x0 + (vn(1) * S);
            y1 = y0 + (vn(2) * S);
            x2 = x0 - (vn(1) * S);
            y2 = y0 - (vn(2) * S);
            hp(k) = plot([x2;x1],[y2;y1],'Color',thiscolor,'LineWidth',2);
            hold on;
        end
    end

    if mod(k,100) == 0
        fprintf(1,'%d\n',length(x)-k);
    end

end
hold off
view(0,-90)
set(gca,'XLim',[min(x) max(x)])
set(gca,'YLim',[min(y) max(y)])
set(gca, 'Units','normalized', 'Position',[0 0 1 1]);
axis off