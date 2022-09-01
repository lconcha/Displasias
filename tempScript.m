
f = '/home/lconcha/Downloads/streamlines.json';
txt = fileread(f);

json = jsondecode(txt);


% praw = [rand(1,100).*0.05 rand(1,50)];
% pcorr = mafdr(praw,'BHFDR',true);
% 
% 
% plot(praw,'. k')
% hold on
% refline(0,0.05)
% plot(pcorr,'. r');
% 
% 
% figure
% 
% subplot(1,2,1)
% scatter(praw,pcorr)
% xlabel('p_{raw}')
% ylabel('p_{corr}')
% 
% subplot(1,2,2)
% idx = pcorr<0.05;
% scatter(praw(idx),pcorr(idx))
% set(gca,'YLim',[0 0.1]);
% set(gca,'XLim',[0 0.1]);
% xlabel('p_{raw}')
% ylabel('p_{corr}')
% 

