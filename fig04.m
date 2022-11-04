%% fig 04
clc; clear all; 
%
sub_dir   = 'c:\Users\Daan\Documents\PhD - SALTI\02_Paper_1\01_Data\04_Scripts\SALTIDE\Update_march_2020\';
Struc_dir = [sub_dir '\Data_and_experiments\Data\'];
save_dir  = [sub_dir 'Data_and_experiments\Figures\'];
load([Struc_dir 'data_schelde.mat']);

%%
PRINT =  1;
nr_sp =  7;
sp_lb = char(97:122);
dis   = [30,57.9,62.2,76.1,90.1]; % distance t.o.v. barrier island 

init_fig(21.5,15,12)
time   = data_schelde.time.data;
xLims  = [datenum('2016-06-01') datenum('2020-01-01')];

for ii = 1:5
    ax(ii) = subplot(nr_sp,1,ii+1); hold(ax(ii),'on'); box(ax(ii),'on');  
    
    loc = eval(['data_schelde.S' num2str(ii-1) '.station']);
    loc = strrep(loc,'Zeeschelde','');  loc = strrep(loc,'-Boven',''); loc = strrep(loc,'SF',''); 
    sx  = eval(['data_schelde.S' num2str(ii-1) '.data']);
    sxg = SALTIDE_quick_godin(sx,time); sxg(isnan(sx)) = NaN;
    
    plot(ax(ii),time,sx,'k','DisplayName','Observed');
    plot(ax(ii),time,sxg,'r','LineWidth',0.5,'DisplayName','Observed (TA)') ;
    ylim(ax(ii),[0 35]);  xlim(ax(ii),xLims); ylabel(ax(ii),'$S$ (PSU)');
    txt = text(0.025,0.8,['(' sp_lb(ii+1) ')' ' '  loc ' ' num2str(dis(ii)) ' km'],'Units','normalized','FontSize',10);
    set(ax(ii),'Xtick',xLims(1):365/2:xLims(end),'XTickLabel','','FontName','Times New Roman');
end 

ax(6) = subplot(nr_sp,1,1); hold(ax(6),'on'); box(ax(6),'on');  
loc  = data_schelde.S0.station;
loc = strrep(loc,'Zeeschelde',''); loc = strrep(loc,'SF',''); 
  
wlv  = data_schelde.h0.data;
wlvg = SALTIDE_quick_godin(wlv,time); wlv(isnan(wlvg)) = NaN;
plot(ax(6),time,wlv ,'k','DisplayName','Observed');
plot(ax(6),time,wlvg ,'r','DisplayName','Observed (TA)');
ylabel(ax(6),'$\zeta_0$ (m)');xlim(ax(6),xLims); ylim(ax(6),[-7 7]);
txt = text(0.025,0.8,['(' sp_lb(1) ')' ' '  loc],'Units','normalized');
set(ax(6),'Xtick',xLims(1):365/2:xLims(end),'XTickLabel','');

ax(7) = subplot(nr_sp,1,7);
loc  = data_schelde.Qr.station;
loc = strrep(loc,'Zeeschelde','');  loc = strrep(loc,'calc',''); 
Qr   = data_schelde.Qr.data;
plot(ax(7),time,Qr ,'k','DisplayName','Measured')
ylabel(ax(7),'Q$_r$ (m$^3$/s)')
xlim(ax(7),xLims); set(ax(7),'Xtick',xLims(1):365/2:xLims(end),'XTickLabel','');
txt = text(0.025,0.8,['(' sp_lb(7) ')' ' '  loc],'Units','normalized');
set(ax(7),'Xtick',xLims(1):365/2:xLims(end),'XTickLabelRotation',45);
datetick(ax(7),'x','mmm-YYYY','Keeplimits','Keepticks');
ax(7).TickLabelInterpreter = 'latex';
ax(7).YTickLabel(3) = {''};
%%
for xx = 1:length(ax)
   ax(xx).Position(4)= 0.115;
end

lgd   = legend(ax(6),'Location', 'SouthEast','Orientation','Horizontal')
AxPos = get(ax(6),'Position'); lgd.Interpreter = 'latex';
xx    = AxPos(1)+AxPos(3)/2; 
yy    = AxPos(2) +AxPos(4)+0.005 ;
lgd.Position = [xx-0.09  yy  0.18 0.03];
%%
if PRINT 
saveas(gcf,[save_dir filesep 'fig04'  '.pdf']);
close(gcf);
end 