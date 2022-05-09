%% fig 04
clear all; close all; clc;

sub_dir   = 'c:\Users\Daan\Documents\PhD - SALTI\02_Paper_1\01_Data\04_Scripts\SALTIDE\Update_march_2020\';
Struc_dir = [sub_dir '\Data_and_experiments\Data\'];
save_dir  = [sub_dir 'Data_and_experiments\Figures\'];
load([Struc_dir 'data_ems_river.mat']);

PRINT          = 1;
tU             = 6;
dt             = 1/24;
%% Load & filter data

time           = data_ems_river.time.data; % time 

wlv            = data_ems_river.h0.data; %water levels
wlvg           = SALTIDE_quick_godin(wlv,time);
wlvU           = movmean(wlv , [tU/(dt*2) tU/(dt*2)],1,'Endpoints','fill');
wlvF           = wlvg-wlvU; 

Qr             = data_ems_river.Qr.data; % discharge
Qrg            = SALTIDE_quick_godin(Qr,time);
QrU            = movmean(Qr , [tU/(dt*2) tU/(dt*2)],1,'Endpoints','fill');
QrF            = Qrg-QrU; 

S0             = data_ems_river.S0.data; % salinity
S0g            = SALTIDE_quick_godin(S0,time);
S0U            = movmean(S0 , [tU/(dt*2) tU/(dt*2)],1,'Endpoints','fill');
S0F            = S0g-S0U;
S0t            = S0-S0g; 

v0             = data_ems_river.v0.data; % velocity
loc            = data_ems_river.S0.station;
%% Scaled surge induced excursion
[S0r, ~]    = SALTIDE_AmpAndRange(S0t,1.2/dt); %Semi_diurnal rang
[v0r, v0a]  = SALTIDE_AmpAndRange(v0,1.2/dt); %Semi_diurnal range 
E0          = TidalExcursion(v0a,12.25); % estimate excursion

dsdx        = S0r./E0; % 
dsdx_km     = S0r./(E0./1000);
S0nrm       = S0F./dsdx;
S0nrm_km    = S0F./dsdx_km ;
%%  figure 

init_fig(19,7,8)
xLims           = [datenum('2017-10-29') datenum('2018-03-01')];

ax(1) = subplot(1,3,[1 2]); hold(ax(1),'on'); box(ax(1),'on'); 
plot(ax(1),time,S0F./max(S0F) ,'r','LineWidth',1,'LineStyle','-','DisplayName','$\Delta S /max\left(\Delta S \right)$') 
plot(ax(1),time,wlvF./max(wlvF),'k','LineWidth',1,'DisplayName','$\Delta\zeta /max\left(\Delta\zeta \right)$')
plot(ax(1),time,QrF./max(QrF),'b','LineWidth',1,'DisplayName','$\Delta Q /max\left(\Delta Q \right)$') 
xlim(ax(1),xLims ); ylim(ax(1),[-1.5 2]); 
ylb = ylabel(ax(1),'(-)'); set(ylb ,'Interpreter','latex')
set(ax(1),'Xtick',xLims (1):365/12:xLims (end),'XTickLabelRotation',45, 'XTickLabel', {});
lgd = legend(ax(1),'Location', 'NorthEast','Orientation','Vertical'); set(lgd,'Interpreter','latex')
text(ax(1),0.05,0.9,['(a) ' loc],'Units','normalized')

datetick(ax(1),'x','mmm-YYYY','Keeplimits','Keepticks')
set(ax(1),'Xtick',xLims (1):365/12:xLims (end),'XTickLabelRotation',45);

ax_dx       = 0.0; ax_dy       = 0.1;  ax_dxt      = 0.0; ax_dyt      = 0.05;
PosAx1 = get(ax(1),'Position'); PosAx_ad_1 = PosAx1+[ax_dx ax_dy -ax_dx -ax_dy-ax_dyt];
set(ax(1),'Position',PosAx_ad_1);
x1 = PosAx_ad_1(1)+ PosAx_ad_1(3);
y1 = PosAx_ad_1(2)+ PosAx_ad_1(4); 
dx = x1/3; dy = y1/4.7; 
lgd.Position = [x1-dx y1-dy dx dy];


ax(2) =  subplot(1,3,3); hold(ax(2),'on'); box(ax(2),'on'); 
Qtlclb  = quantile(S0U,[0.05 0.95]);
s       = scatter(ax(2),wlvF,S0nrm_km ,5,S0U,'filled'); 
set(s,'MarkerFaceAlpha',0.5);
colormap(ax(2),(bluewhitered(15))); caxis(ax(2),[Qtlclb(1) Qtlclb(end)]);
clb = colorbar;   clb.Label.String = 'PSU'; clb.FontName = 'Times new roman'; 
xlim([-1.1 1.1]); ylim([-4 4]);
xlb = xlabel(ax(2),'$\Delta\zeta$ (m)');  
%ylb = ylabel(ax(2),'$\Delta$S  $\left(\frac{dS}{dx}\right)^{-1}$ (km)')%ylabel({'Surge excursion [km]', 'PSU/(dPSU/dx)'})
ylb = ylabel(ax(2),'$\Delta S \left(\frac{dS}{dx}\right)^{-1}  (km)$')%ylabel({'Surge excursion [km]', 'PSU/(dPSU/dx)'})

xvalNonNan      = wlvF(~isnan(wlvF) & ~isnan(S0nrm_km)); 
yvalNonNan      = S0nrm_km(~isnan(wlvF) & ~isnan(S0nrm_km )); 
R               = corrcoef(xvalNonNan,yvalNonNan )
[p,S]           = polyfit(xvalNonNan,yvalNonNan,1); xx = [-5:0.1:5];
yfitval         = xx*p(1) + p(2);

plot(ax(2),xx,yfitval,'k','LineWidth',1);
%text(ax(2),0.05,0.1,[num2str(round(p(1),2)) 'x +' num2str(round(p(2),2))] ,'Units','normalized')
text(ax(2),0.05,0.9,['(b)   ' 'r: ' num2str(round(R(2,1),2))],'Units','normalized')

PosAx2 = get(ax(2),'Position'); PosAx2 = PosAx2+[+ax_dx ax_dy +0.075 -ax_dy-ax_dyt];
set(ax(2),'Position',PosAx2);
clb.Position = [PosAx2(1)+PosAx2(3)+0.02  PosAx2(2)  0.0171 PosAx2(4)] ;
ax(1).TickLabelInterpreter = 'latex';


if PRINT 
saveas(gcf,[save_dir filesep 'fig04'  '.pdf']);
close(gcf);
end 


