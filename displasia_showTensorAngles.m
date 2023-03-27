plot3([-normSegment(1) normSegment(1)],[-normSegment(2) normSegment(2)],[-normSegment(3) normSegment(3)], ' -k', 'LineWidth',3); hold on


scatter3(0,0,0,'k','filled')

normPDD1= PDD1./norm(PDD1);
normPDD2= PDD2./norm(PDD2);
normPDD3= PDD3./norm(PDD3);

nRxyz = Rxyz ./ norm(Rxyz);


PLANE = createPlane([0 0 0],normSegment,nRxyz);
NORMAL = planeNormal(PLANE);

normPDDs = [normPDD1;normPDD2;normPDD3];

for n = 1 : size(normPDDs,1)
   plot3([-normPDDs(n,1) normPDDs(n,1)],[-normPDDs(n,2) normPDDs(n,2)],[-normPDDs(n,3) normPDDs(n,3)], '.-k');
   text(normPDDs(n,1), normPDDs(n,2), normPDDs(n,3), num2str(n));
   p = [normPDDs(n,1) normPDDs(n,2) normPDDs(n,3)];
   thisalpha = rad2deg(anglePoints3d(normSegment,p));
   if thisalpha > 90
       thisalpha = rad2deg(anglePoints3d(normSegment,-p)); % we do not care if it is parallel or antiparallel
   end
   alphas(n) = thisalpha;
   thisbeta  = rad2deg(anglePoints3d(NORMAL,p));
   if thisbeta > 90
       thisbeta  = rad2deg(anglePoints3d(NORMAL,-p)); % we do not care if it is parallel or antiparallel
   end
   betas(n)  = thisbeta;

end



plot3([-normPDDs(indexpar,1) normPDDs(indexpar,1)],[-normPDDs(indexpar,2) normPDDs(indexpar,2)],[-normPDDs(indexpar,3) normPDDs(indexpar,3)], ' -r', 'LineWidth',2);
plot3([-normPDDs(indexperp,1) normPDDs(indexperp,1)],[-normPDDs(indexperp,2) normPDDs(indexperp,2)],[-normPDDs(indexperp,3) normPDDs(indexperp,3)], ' -b', 'LineWidth',2);




set(gca,'XLim',[-1 1],'YLim',[-1 1],'ZLim',[-1 1]);


hPlane = drawPlane3d(PLANE);
set(hPlane,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.5)





%angle= 2 * atand(norm(x*norm(y) - norm(x)*y) / norm(x * norm(y) + norm(x) * y))

pPar  = [normPDDs(indexpar,1),normPDDs(indexpar,2),normPDDs(indexpar,3)];
legend('streamline','origin',...
        ['1: $\alpha$='    num2str(alphas(1),'%1.0f') '; $\beta$=' num2str(betas(1),'%1.0f') ' deg'],...
        ['2: $\alpha$='    num2str(alphas(2),'%1.0f') '; $\beta$=' num2str(betas(2),'%1.0f') ' deg'],...
        ['3: $\alpha$='    num2str(alphas(3),'%1.0f') '; $\beta$=' num2str(betas(3),'%1.0f') ' deg'],...
        'par','perp',...
        'Slice plane', 'Interpreter', 'latex')

% drawVector3d([0 0 0],PDD1,'LineWidth',4);
% drawVector3d([0 0 0],PDD2);
% drawVector3d([0 0 0],PDD3);
% drawVector3d([0 0 0],normSegment,'LineWidth',5)

