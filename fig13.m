%% fig 13
clear all; close all; clc;
%%  Load the model output
modelname = 'eq10_cal';
sub_dir   = 'c:\Users\Daan\Documents\PhD - SALTI\02_Paper_1\01_Data\04_Scripts\SALTIDE\Update_march_2020\';
struc_dir = [sub_dir '\Data_and_experiments\Experiments\'];
save_dir  = [sub_dir 'Data_and_experiments\Figures\'];
load([struc_dir  modelname '.mat']);

PRINT    = 1;
%%
Struc_dir2 = [sub_dir '\Data_and_experiments\Data\'];
load([Struc_dir2 'data_ems_river.mat']);
time       = eval([modelname '.OP1.invars.time']) +data_ems_river.time.data(1);

%%
Locs     = {'Emspier','Pogum','Gandersum','Terborg'}
xLims    = [datenum('2017-05-01') datenum('2019-05-01')];
abc      = char(97:122);
Colors   = {'k','b','g' ,[0.5 0.5 0.5]};
pars     = {'DxD0_pr','cst_stage_QD0','cst_tide_QD0','cst_surge_QD0'};
offset   = [[0 0 0 0];[0 0 0 0];[-0.6 0 0 0.6];[-0.15 0 0 0.15]];

init_fig(21.5,10,8)
ax(1) = subplot(3,2,[1 2]); hold(ax(1),'on');  box(ax(1),'on');  ylim(ax(1), [0 4500])
for ll = [1 4]
    data  = eval([modelname '.OP' num2str(ll) '.pred.KQr_D0']);
    gp    = eval([modelname '.OP' num2str(ll) '.prop.gp' ]);
    plot(ax(1),time(gp),data,'LineWidth',1,'Color',Colors{ll},'DisplayName',Locs{ll})
end
text(ax(1),0.05,0.8,'(a)','Units','normalized','BackgroundColor','w','Fontsize',10);
set(ax(1),'Xtick',xLims(1):365/2:xLims(2),'XTickLabelRotation',0,'XtickLabels','','FontSize', 10);
ylabel(ax(1),'$Q_r/D_0$ (m)','Interpreter','Latex','FontSize', 12)

for ii = 1:4
for ll = [4 1]
ax(ii+1) = subplot(3,2,ii+2); hold(ax(ii+1),'on'); box(ax(ii+1),'on');  
if strcmp(pars{ii},'DxD0_pr')
    data = 1+eval([modelname '.OP' num2str(ll) '.pred.' pars{ii} ]);
else 
    data = eval([modelname '.OP' num2str(ll) '.pred.' pars{ii} ]);    
end 
plot(ax(ii+1),time,data+offset(ii,ll),'LineWidth',0.1,'Color',Colors{ll},'DisplayName',Locs{ll})
text(ax(ii+1),0.05,0.8,['(' abc(ii+1) ')' ],'Units','normalized','BackgroundColor','w','Fontsize',10); 
set(ax(ii+1),'Xtick',xLims(1):365/2:xLims(2),'XTickLabelRotation',45,'XtickLabels','','FontSize', 10);
end 
end 
plot(ax(3),[time(1) time(end)],[-1 -1],'LineWidth',1,'Color','r','LineStyle','--')
xlim(ax,[xLims(1) xLims(2)]); ylim(ax(2),[0 1]); ylim(ax(3),[-2 0]); ylim(ax(4),[-1.6 1.6]); ylim(ax(5),[-0.45 0.45]); 
lgd = legend(ax(1),'Location', 'Northeast','Orientation','Horizontal')
lgd.Interpreter = 'Latex';
ylabel(ax(2),'$D_s/D_0$ (-)','Interpreter','Latex','FontSize', 12)
ylabel(ax(3),'River (-)','Interpreter','Latex','FontSize', 12)
ylabel(ax(4),'Tides (-)','Interpreter','Latex','FontSize', 12)
ylabel(ax(5),'Surges (-)','Interpreter','Latex','FontSize', 12)


ax(1).TickLabelInterpreter = 'latex';
ax(4).TickLabelInterpreter = 'latex';
ax(5).TickLabelInterpreter = 'latex';

datetick(ax([1]),'x','mmm-YYYY','Keeplimits','Keepticks')  
datetick(ax([4]),'x','mmm-YYYY','Keeplimits','Keepticks')  
datetick(ax([5]),'x','mmm-YYYY','Keeplimits','Keepticks')  

if PRINT 
saveas(gcf,[save_dir filesep 'fig13'  '.pdf']);
close(gcf);
end 