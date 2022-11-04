%%fig 12 Parker macready diagram
clear all; close all; clc;

sub_dir   = 'c:\Users\Daan\Documents\PhD - SALTI\02_Paper_1\01_Data\04_Scripts\SALTIDE\Update_march_2020\';
Struc_dir = [sub_dir '\Data_and_experiments\Data\'];
save_dir  = [sub_dir 'Data_and_experiments\Figures\'];
load([Struc_dir 'data_ems_river.mat']);
load([Struc_dir 'data_schelde.mat']);

PRINT = 1;
%% Properties Ems 
C       = 65; 
g       = 9.81 
Cd      = g/C^2; % Drag coefficient
Betha   = 7.7*10^-4
g       = 9.81 
h0      = 6;             % mouth depth Ems (Gisen)     
B0      = 1000;
A0      = B0*h0; 
Qr      = data_ems_river.Qr.data;
T       = 12.25;
S0      = data_ems_river.S0f.data;
v0      = data_ems_river.v0.data; % velocity

Omega       = 2*pi./(T*3600); 
N0          = (g*Betha.*S0 ./h0).^0.5;  % Bouyancy frequency (at the mouth). 
[v0r, v0a]  = SALTIDE_AmpAndRange(v0,1.2/1/24); %Semi_diurnal range 
Ur          = Qr./A0;

Mi      = ((Cd*v0a.^2)./(Omega.*N0.*h0^2)).^0.5; % mixing number
Frf     = Ur./(g*Betha.*S0.* h0).^0.5;

Mi_ems_m  = nanmedian(Mi);
Frf_ems_m = nanmedian(Frf);
Mi_ems_std  = quantile(Mi, [0.1 0.9])-Mi_ems_m;
Frf_ems_std = quantile(Frf, [0.1 0.9])-Frf_ems_m;
%%
%% Properties Schelde
C       = 35; 
g       = 9.81 
Cd      = g/C^2; % Drag coefficient  
Betha   = 7.7*10^-4

h0      = 9.4;             % mouth depth schelde (Gisen)     
B0      = 4200;
A0      = B0*h0; 
g       = 9.81;
Qr      = data_schelde.Qr.data;
T       = 12.25;
S0      = data_schelde.S0f.data;
v0      = data_schelde.v2.data; % velocity

Omega       = 2*pi./(T*3600); 
N0          = (g*Betha.*S0 ./h0).^0.5;  % Bouyancy frequency (at the mouth). 
[v0r, v0a]  = SALTIDE_AmpAndRange(v0,1.2/1/24); %Semi_diurnal range 
Ur          = Qr./A0;

Mi      = ((Cd*v0a.^2)./(Omega.*N0.*h0^2)).^0.5; % mixing number
Frf     = Ur./(g*Betha.*S0.* h0).^0.5;

Mi_schelde_m    = nanmedian(Mi);
Frf_schelde_m   = nanmedian(Frf);
Mi_schelde_std  = quantile(Mi, [0.1 0.9])-Mi_schelde_m;
Frf_schelde_std = quantile(Frf, [0.1 0.9])-Frf_schelde_m;

%%



Frfv = [10^-4,10^1];
miv  = ((3.4^0.5.*Frfv.^(1/3))).^0.5;

wmM  = [0.9 1.8];
wmFr = [10^-4 0.007];


init_fig(21.5,8,12)
ax(1) = subplot(1,2,1); hold(ax(1),'on'); box(ax(1),'on'); 
loglog(ax(1),miv,Frfv,'r','LineWidth',2,'HandleVisibility','off')
loglog(ax(1),wmM,wmFr,'r--','LineWidth',1,'HandleVisibility','off')

er1 = errorbar(Mi_ems_m,Frf_ems_m,Frf_ems_std(1),Frf_ems_std(2),Mi_ems_std(1),Mi_ems_std(2),'o',"MarkerEdgeColor","k","MarkerFaceColor",'b','Color','k','DisplayName','Ems')
er2 = errorbar(Mi_schelde_m,Frf_schelde_m,Frf_schelde_std(1),Frf_schelde_std(2),Mi_schelde_std(1),Mi_schelde_std(2),'o',"MarkerEdgeColor","k","MarkerFaceColor",'green','Color','k','DisplayName','Schelde')
xlb = xlabel(ax(1),'$M$','FontSize', 12);  
ylb = ylabel(ax(1),'$Fr_t$','FontSize', 12)
ax(1).YAxis.Scale = 'log'
ax(1).XAxis.Scale = 'log'
ax(1).XTick       = [0.2,0.5,1,2]

text(ax(1),0.05,0.9,'(a)','Units','normalized')
text(ax(1),0.82,0.17,{'Well','mixed'},'Units','normalized')
text(ax(1),0.60,0.15,'SIPS','Units','normalized')
text(ax(1),0.70,0.65,{'Partially','mixed'},'Units','normalized')
text(ax(1),0.10,0.25,{'Fjord'},'Units','normalized')
text(ax(1),0.30,0.80,{'Salt wedge'},'Units','normalized')
text(ax(1),0.25,0.55,{'Strongly','stratified'},'Units','normalized')

xlim(ax(1),[0.1, 2.5])
ylim(ax(1),[0, 1])


%%
lb_h0   = [2872.340426, 6000];
dsdx    = [ 0.260869565,0.40];
lb_h02  = [6029.4,2826.0,11785.7,14285.7];
dsdx2   = [0.25,0.64,0.75,0.55];
names   = {'Delaware','Tejo','Elbe','Incomati'};

ax(2) = subplot(1,2,2); hold(ax(2),'on'); box(ax(2),'on')
xlb = xlabel(ax(2),'$L_a/h_0 (-)$','FontSize', 12)
ylb = ylabel(ax(2),'$S_0/l_s \left(\frac{PSU}{km}\right)$','FontSize', 12);  
plot(ax(2),lb_h0(2),dsdx(2),'-s','Color', [0 0 0 0],'LineWidth',1,'DisplayName','Ems','MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',10) 
plot(ax(2),lb_h0(1),dsdx(1),'-s','Color', [0 0 0 0],'LineWidth',1,'DisplayName','Schelde','MarkerFaceColor','g','MarkerEdgeColor','k','MarkerSize',10) 
scatter(ax(2),lb_h02,dsdx2,40,'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[0.5 0.5 0.5],...
              'LineWidth',0.5,'HandleVisibility','off')
          
%ax(2).YAxis.Scale = 'log';
ax(2).XAxis.Scale = 'log';
for nn = 1:length(names)
    txt = text(ax(2),lb_h02(nn)+100,dsdx2(nn)+0.05,names{nn});
    txt.Interpreter = 'latex';
end 
xlim(ax(2),[0 100000]); ylim(ax(2),[0 1.5]);

text(ax(2),0.05,0.9,'(b)','Units','normalized')
lgd =legend(ax(2),'Location','NorthEast'); lgd.Interpreter = 'Latex';

if PRINT 
saveas(gcf,[save_dir filesep 'fig12'  '.pdf']);
close(gcf);
end 
