%% subfig 01
clear all; close all; clc;

sub_dir   = '..';
save_dir  = [sub_dir 'Data_and_experiments\Figures\'];
PRINT     = 1;
%% Diminsonless parameters
x       = 0:0.01:3; 
k       = 0.25:0.25:0.75;
Ds      = 0.1:0.45:1;
Gamma   = 1;
%% Curve
D_set025                = (1 - Ds'.*k(1)./Gamma.* (exp(x.*Gamma)-1));
D_set025(D_set025 < 0)  = 0;
S_set025                = D_set025.^(1./k(1));

D_set050                = (1 - Ds'.*k(2)./Gamma.* (exp(x.*Gamma)-1));
D_set050(D_set050 < 0)  = 0;
S_set050                = D_set050.^(1./k(2));

D_set075                = (1 - Ds'.*k(3)./Gamma.* (exp(x.*Gamma)-1));
D_set075(D_set075 < 0)  = 0;
S_set075                = D_set075.^(1./k(3));

%%
Colors = linspecer(length(Ds));

init_fig(19,6,8)

ax(1) = subplot(1,3,1); hold(ax(1),'on'); box(ax(1),'on');grid(ax(1),'on');
for ii = 1:length(Ds)
plot(ax(1),x,S_set025(ii,:),'LineWidth',1.5,'Color',Colors(ii,:))
end 
text(ax(1),0.55,0.9,[ 'K = ' num2str(k(1),2)],'Units','normalized')
xlabel(ax(1),'x$^*$'); ylabel(ax(1),'S$^*$')

ax(2) = subplot(1,3,2); hold(ax(2),'on');  box(ax(2),'on');grid(ax(2),'on');
for ii = 1:length(Ds)
plot(ax(2),x,S_set050(ii,:),'LineWidth',1.5,'Color',Colors(ii,:))
end
text(ax(2),0.55,0.9,[ 'K = ' num2str(k(2),2)],'Units','normalized')
xlabel(ax(2),'x$^*$')

ax(3) = subplot(1,3,3); hold(ax(3),'on'); box(ax(3),'on'); grid(ax(3),'on');
for ii = 1:length(Ds)
plot(ax(3),x,S_set075(ii,:),'LineWidth',1.5,'Color',Colors(ii,:))
end
text(ax(3),0.55,0.9,[ 'K = ' num2str(k(3),2)],'Units','normalized')
xlabel(ax(3),'x$^*$')
lgd = legend(ax(3),{'D^* = 0.10','D^* = 0.55','D^* = 1.00','D^* = 1.45','D^* = 1.90'}...
    ,'Position',[0.875 0.5 0.05 0.1]); 

xlim(ax,[0 3])


if PRINT 
saveas(gcf,[save_dir filesep 'subfig01'  '.pdf']);
close(gcf);
end 
