%% fig 03
clc; clear all; 
%
sub_dir   = '..';
Struc_dir = [sub_dir '\Data_and_experiments\Data\'];
save_dir  = [sub_dir 'Data_and_experiments\Figures\'];
load([Struc_dir 'data_ems_river.mat']);

%%
PRINT = 0;
nr_sp =  7;
sp_lb = char(97:122);
dis   = [39,48.7,54.5,58.2,65.3]; % distance t.o.v. barrier island 

init_fig(19,20,8)
time   = data_ems_river.time.data;
xLims  = [datenum('2017-05-01') datenum('2019-05-01')];

for ii = 1:5
    ax(ii) = subplot(nr_sp,1,ii); hold(ax(ii),'on'); box(ax(ii),'on');  
    
    loc = eval(['data_ems_river.S' num2str(ii-1) '.station']);
    sx  = eval(['data_ems_river.S' num2str(ii-1) '.data']);
    sxg = SALTIDE_quick_godin(sx,time); sxg(isnan(sx)) = NaN;
    
    plot(ax(ii),time,sx,'k','DisplayName','Observed');
    plot(ax(ii),time,sxg,'r','LineWidth',0.5,'DisplayName','Observed (TA)') ;
    ylim(ax(ii),[0 40]);  xlim(ax(ii),xLims); ylabel(ax(ii),'$S$ (PSU)');
    txt = text(0.025,0.8,['(' sp_lb(ii) ')' ' '  loc ' ' num2str(dis(ii)) ' km'],'Units','normalized','FontSize',10);
    set(ax(ii),'Xtick',xLims(1):365/6:xLims(end),'XTickLabel','','FontName','Times New Roman');
end 

lgd   = legend(ax(1),'Location', 'SouthEast','Orientation','Horizontal')
AxPos = get(ax(1),'Position'); 
xx    = AxPos(1)+AxPos(3)/2; 
yy    = AxPos(2) +AxPos(4)+0.005 ;
lgd.Position = [xx-0.09  yy  0.18 0.03];

ax(6) = subplot(nr_sp,1,6); hold(ax(6),'on'); box(ax(6),'on');  
loc  = data_ems_river.S1.station;
wlv  = data_ems_river.h0.data;
wlvg = SALTIDE_quick_godin(wlv,time); wlv(isnan(wlvg)) = NaN;
plot(ax(6),time,wlv ,'k','DisplayName','Measured');
plot(ax(6),time,wlvg ,'r','DisplayName','Measured');
ylabel(ax(6),'$\zeta_0$ (m)');xlim(ax(6),xLims); 
txt = text(0.025,0.8,['(' sp_lb(6) ')' ' '  loc],'Units','normalized');
set(ax(6),'Xtick',xLims(1):365/6:xLims(end),'XTickLabel','');

ax(7) = subplot(nr_sp,1,7);
loc  = data_ems_river.Qr.station;
Qr   = data_ems_river.Qr.data;
plot(ax(7),time,Qr ,'k','DisplayName','Measured')
ylabel(ax(7),'Q$_r$ (m$^3$/s)')
xlim(ax(7),xLims); set(ax(7),'Xtick',xLims(1):365/6:xLims(end),'XTickLabel','');
txt = text(0.025,0.8,['(' sp_lb(7) ')' ' '  loc],'Units','normalized');
set(ax(7),'Xtick',xLims(1):365/6:xLims(end),'XTickLabelRotation',45);
datetick(ax(7),'x','mmm-YYYY','Keeplimits','Keepticks');
ax(7).TickLabelInterpreter = 'latex';

if PRINT 
saveas(gcf,[save_dir filesep 'fig03'  '.pdf']);
close(gcf);
end 