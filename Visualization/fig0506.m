%% fig 05 and 06
clear all; close all; clc;

sub_dir   = '..';
Struc_dir = [sub_dir '\Data_and_experiments\Experiments\'];
save_dir  = [sub_dir 'Data_and_experiments\Figures\'];
PRINT     = 1;
%%
Struc_dir2 = [sub_dir '\Data_and_experiments\Data\'];
load([Struc_dir2 'data_ems_river.mat']);


%% Main text figure 
load([Struc_dir 'eq10_pred.mat']);
model = eq10_pred;
time  = model.OP1.invars.time +data_ems_river.time.data(1);

Locs     = {'Emspier','Pogum','Gandersum','Terborg'}
xLims    = [datenum('2017-05-01') datenum('2019-05-01')];

%% plot fig05

% colors
rr = [227, 27, 35, 100]./255; 
ot = [255, 195, 37]./255; 
pt = [0, 92, 171]./255; 

% scale location text label
ylm     = 37; % ylim 
ylab    = 32; % location text label
yt      = ylab/ylm; % scaled location text label
Offsets = [30 22.5 15 7.5]; % off-set residuals

init_fig(19,20,8)

% loc - 1 
ax(1) = subplot(5,1,1); hold(ax(1),'on'); box(ax(1),'on');  
txt = text(ax(1),0.05,0.8,['(a) ' Locs{1}],'Units','normalized');
txt.BackgroundColor = 'w'; txt.FontSize = 10;
timev = time(model.OP1.prop.gpv & ~model.OP1.prop.gp);

flt = [timev(1) timev(1) timev(end) timev(end)];
fly = [-1000 1000 1000 -1000]; 
flc = [0.5 0.5 0.5];
fl = fill(ax(1),flt,fly,flc,'HandleVisibility','Off','FaceAlpha',0.5,'EdgeColor',flc);
plot(ax(1),time, model.OP1.invars.Sx,'Color',[0 0 0 ],'DisplayName','Observed');
plot(ax(1),time, model.OP1.pred.Sx_pred,'Color',[rr],'DisplayName','Predicted')
plot(ax(1),time, movmean(model.OP1.invars.Sx,[1*24 1*24],'Endpoints','fill'),'Color',ot,'DisplayName','Observed (TA)','LineWidth',1.5)
plot(ax(1),time, movmean(model.OP1.pred.Sx_pred,[1*24 1*24],'Endpoints','fill'),'Color',pt,'DisplayName','Predicted (TA)','LineWidth',1.5)

xt   = (timev(1)- time(1))/(timev(end)-time(1))
txt1 = text(ax(1),xt-0.02,yt,'$\leftarrow$ Calibration','Units','normalized','HorizontalAlignment', 'right');  txt1.FontSize = 10;
txt2 = text(ax(1),xt+0.02,yt,'Predictions $\rightarrow$','Units','normalized','HorizontalAlignment', 'left');  txt2.FontSize = 10;
ylabel(ax(1),'S (PSU)','Interpreter','Latex')
lgd1 = legend(ax(1),'Location', 'North','Orientation','Horizontal')
set(ax(1),'Xtick',xLims(1):365/4:xLims(2),'XTickLabelRotation',45,'XtickLabels','');


% loc - 2 
ax(2) = subplot(5,1,2); hold(ax(2),'on'); box(ax(2),'on');  
txt = text(ax(2),0.05,0.8,['(b) ' Locs{2}],'Units','normalized','BackgroundColor','w','Fontsize',10);
fl = fill(ax(2),flt,fly,flc,'HandleVisibility','Off','FaceAlpha',0.5,'EdgeColor',flc);
plot(ax(2),time,model.OP2.invars.Sx,'Color',[0 0 0 ],'DisplayName','Observed');
plot(ax(2),time, model.OP2.pred.Sx_pred,'Color',rr,'DisplayName','Predicted')
plot(ax(2),time, movmean(model.OP2.invars.Sx,[1*24 1*24],'Endpoints','fill'),'Color',ot,'DisplayName','Observed (TA)','LineWidth',1.5)
plot(ax(2),time, movmean(model.OP2.pred.Sx_pred,[1*24 1*24],'Endpoints','fill'),'Color',pt,'DisplayName','Predicted (TA)','LineWidth',1.5)
ylabel(ax(2),'S (PSU)','Interpreter','Latex')
set(ax(2),'Xtick',xLims(1):365/4:xLims(2),'XTickLabelRotation',45,'XtickLabels','');

% loc - 3 
ax(3) = subplot(5,1,3); hold(ax(3),'on'); box(ax(3),'on');  
txt   = text(ax(3),0.05,0.8,['(c) ' Locs{3}],'Units','normalized','BackgroundColor','w','Fontsize',10); 
fl    = fill(ax(3),flt,fly,flc,'HandleVisibility','Off','FaceAlpha',0.5,'EdgeColor',flc);
plot(ax(3),time,model.OP3.invars.Sx,'Color',[0 0 0 ],'DisplayName','Observed');
plot(ax(3),time, model.OP3.pred.Sx_pred,'Color',rr,'DisplayName','Predicted')
plot(ax(3),time, movmean(model.OP3.invars.Sx,[1*24 1*24],'Endpoints','fill'),'Color',ot,'DisplayName','Observed (TA)','LineWidth',1.5)
plot(ax(3),time, movmean(model.OP3.pred.Sx_pred,[1*24 1*24],'Endpoints','fill'),'Color',pt,'DisplayName','Predicted (TA)','LineWidth',1.5)
ylabel(ax(3),'S (PSU)','Interpreter','Latex')
set(ax(3),'Xtick',xLims(1):365/4:xLims(2),'XTickLabelRotation',45,'XtickLabels','');

% loc - 4
ax(4) = subplot(5,1,4); hold(ax(4),'on'); box(ax(4),'on');  
txt   = text(ax(4),0.05,0.8,['(d) ' Locs{4}],'Units','normalized','BackgroundColor','w','Fontsize',10);
fl    = fill(ax(4),flt,fly,flc,'HandleVisibility','Off','FaceAlpha',0.5,'EdgeColor',flc);
plot(ax(4),time,model.OP4.invars.Sx,'Color',[0 0 0 ],'DisplayName','Observed');
plot(ax(4),time, model.OP4.pred.Sx_pred,'Color',rr,'DisplayName','Predicted')
plot(ax(4),time, movmean(model.OP4.invars.Sx,[1*24 1*24],'Endpoints','fill'),'Color',ot,'DisplayName','Observed (TA)','LineWidth',1.5)
plot(ax(4),time, movmean(model.OP4.pred.Sx_pred,[1*24 1*24],'Endpoints','fill'),'Color',pt,'DisplayName','Predicted (TA)','LineWidth',1.5)
ylabel(ax(4),'S (PSU)','Interpreter','Latex')
set(ax(4),'Xtick',xLims(1):365/4:xLims(2),'XTickLabelRotation',45,'XtickLabels','');

% residuals
ax(5)   = subplot(5,1,5); hold(ax(5),'on'); box(ax(5),'on');  
Colors  = gray(5);
txt     = text(ax(5),0.05,0.8,['(e) '],'Units','normalized','BackgroundColor','w','Fontsize',10);
for ii = 1:4
res  = eval(['model.OP' num2str(ii) '.invars.Sx' ])-eval(['model.OP' num2str(ii) '.pred.Sx_pred' ]);
plot(ax(5),time,res + Offsets(ii) ,'Color',Colors(ii,:),'DisplayName',[Locs{ii} ' + ' num2str(Offsets(ii))]) 
end
ylabel(ax(5),'Residual (PSU)','Interpreter','Latex') 
set(ax(5),'Xtick',xLims(1):365/4:xLims(2),'XTickLabelRotation',45,'XtickLabels','');
datetick(ax(5),'x','mmm-YYYY','Keeplimits','Keepticks')
lgd2 = legend(ax(5),'Location', 'North','Orientation','Horizontal')
ylim(ax,[0 ylm]);
xlim(ax,[xLims(1) xLims(2)]);
ax(5).TickLabelInterpreter = 'latex';
lgd1.Position  = [0.1741    0.93    0.6866    0.025];
lgd2.Position  = [0.1741    0.24    0.6866    0.025];

if PRINT 
saveas(gcf,[save_dir filesep 'fig05'  '.pdf']);
close(gcf);
end 

%% plot fig06
clear ax
xLims       = [datenum('2018-12-25') datenum('2019-01-25')];
xLims_cl    = [datenum('2018-12-25') datenum('2019-01-25')];
xLims_su    = [datenum('2018-12-25') datenum('2019-01-25')];
block1      = [datenum('2018-12-31') datenum('2019-01-4')];
block2      = [datenum('2019-01-17') datenum('2019-01-21')];

init_fig(19,12,8)
ax(1) = subplot(3,2,[1 2]); hold(ax(1),'on'); box(ax(1),'on');  
txt = text(ax(1),0.05,0.8,['(a) ' Locs{3}],'Units','normalized','BackgroundColor','w','Fontsize',10); 
fl_1 = fill(ax(1),[block1(1) block1(1) block1(end) block1(end)],fly,flc,'HandleVisibility','Off','FaceAlpha',0.5,'EdgeColor',flc)
fl_2 = fill(ax(1),[block2(1) block2(1) block2(end) block2(end)],fly,flc,'HandleVisibility','Off','FaceAlpha',0.5,'EdgeColor',flc)
plot(ax(1),time,model.OP3.invars.Sx,'Color','k','DisplayName','Observed');
plot(ax(1),time, model.OP3.pred.Sx_pred,'Color',rr,'DisplayName','Predicted')
ylabel(ax(1),'S (PSU)','Interpreter','Latex'); xlim(ax(1),xLims); ylim(ax(1),[0 ylm]);
legend(ax(1),'Location', 'North','Orientation','Horizontal')
set(ax(1),'Xtick',xLims(1):5:xLims(2),'XTickLabelRotation',0,'XtickLabels','','TickLabelInterpreter','Latex');
datetick(ax(1),'x','dd-mmm','Keeplimits','Keepticks')

% Clipping event 
ax(2) = subplot(3,2,3); hold(ax(2),'on'); box(ax(2),'on');  
txt = text(ax(2),0.05,0.8,['(b) Strom-surge event' ],'Units','normalized','BackgroundColor','w','Fontsize',10);
plot(ax(2),time,model.OP2.invars.Sx,'Color',[0 0 0 ],'DisplayName','Observed');
plot(ax(2),time, model.OP2.pred.Sx_pred,'Color',rr,'DisplayName','Predicted')
ylabel(ax(2),'S (PSU)','Interpreter','Latex')
set(ax(2),'Xtick',xLims_cl(1):1:xLims_cl(2),'XTickLabelRotation',0,'XtickLabels','','TickLabelInterpreter','Latex');
datetick(ax(2),'x','dd-mmm','Keeplimits','Keepticks')
xlim(ax(2),[block1(1) block1(2)]);
ylim(ax(2),[0 ylm]);

% Surge event 
ax(3) = subplot(3,2,4); hold(ax(3),'on'); box(ax(3),'on');  
txt = text(ax(3),0.05,0.8,['(c) Clipped salinity signal ' ],'Units','normalized','BackgroundColor','w','Fontsize',10); 
plot(ax(3),time,model.OP3.invars.Sx,'Color',[0 0 0 ],'DisplayName','Observed');
plot(ax(3),time, model.OP3.pred.Sx_pred,'Color',rr,'DisplayName','Predicted')
ylabel(ax(3),'S (PSU)','Interpreter','Latex')
set(ax(3),'Xtick',xLims_su(1):1:xLims_su(2),'XTickLabelRotation',0,'XtickLabels','','TickLabelInterpreter','Latex');
datetick(ax(3),'x','dd-mmm','Keeplimits','Keepticks')
xlim(ax(3),[block2(1) block2(2)]);
ylim(ax(3),[0 ylm]);

% Power Spectrum
ofac           = 4;
dt             = 1/24;
[pxxin,fin]    = plomb(model.OP3.invars.Sx,time,1/(2*dt),ofac,'power');
[pxxout,fout]  = plomb(model.OP3.pred.Sx_pred,time,1/(2*dt),ofac,'power');

ax(5) = subplot(3,2,[5 6]); hold(ax(5),'on'); box(ax(5),'on');  
txt = text(ax(5),0.05,0.8,['(d) Power spectrum' ],'Units','normalized','BackgroundColor','w','Fontsize',10); 
plot(ax(5),fin,pxxin,'k','LineWidth',1,'Displayname','Observed')
plot(ax(5),fout,pxxout,'Color',[1, 0, 0, 0.35],'LineWidth',1,'Displayname','Predicted')
ylabel(ax(5),'power ($PSU^2$)','Interpreter','Latex')
xlabel(ax(5),'Frequency (cpd)','Interpreter','Latex')
set(ax(5), 'YScale', 'log','TickLabelInterpreter','Latex'); 
xlim(ax(5),[0 5]); ylim(ax(5),[1*10^-8 20]);

if PRINT 
saveas(gcf,[save_dir filesep 'fig06'  '.pdf']);
close(gcf);
end 


%% Supplementory figure (sub01) 
clear ax
load([Struc_dir 'eq9_pred.mat']);
model    = eq9_pred;
xLims    = [datenum('2017-05-01') datenum('2019-05-01')];

init_fig(19,20,8)

% loc - 1 
ax(1) = subplot(5,1,1); hold(ax(1),'on'); box(ax(1),'on');  
txt = text(ax(1),0.05,0.8,['(a) ' Locs{1}],'Units','normalized');
txt.BackgroundColor = 'w'; txt.FontSize = 10;
timev = time(model.OP1.prop.gpv & ~model.OP1.prop.gp);

flt = [timev(1) timev(1) timev(end) timev(end)];
fly = [-1000 1000 1000 -1000]; 
flc = [0.5 0.5 0.5];
fl = fill(ax(1),flt,fly,flc,'HandleVisibility','Off','FaceAlpha',0.5,'EdgeColor',flc);
plot(ax(1),time, model.OP1.invars.Sx,'Color',[0 0 0 ],'DisplayName','Observed');
plot(ax(1),time, model.OP1.pred.Sx_pred,'Color',[rr],'DisplayName','Predicted')
plot(ax(1),time, movmean(model.OP1.invars.Sx,[1*24 1*24],'Endpoints','fill'),'Color',ot,'DisplayName','Observed (TA)','LineWidth',1.5)
plot(ax(1),time, movmean(model.OP1.pred.Sx_pred,[1*24 1*24],'Endpoints','fill'),'Color',pt,'DisplayName','Predicted (TA)','LineWidth',1.5)

xt   = (timev(1)- time(1))/(timev(end)-time(1))
txt1 = text(ax(1),xt-0.02,yt,'$\leftarrow$ Calibration','Units','normalized','HorizontalAlignment', 'right');  txt1.FontSize = 10;
txt2 = text(ax(1),xt+0.02,yt,'Predictions $\rightarrow$','Units','normalized','HorizontalAlignment', 'left');  txt2.FontSize = 10;
ylabel(ax(1),'S (PSU)','Interpreter','Latex')
lgd1 = legend(ax(1),'Location', 'North','Orientation','Horizontal')
set(ax(1),'Xtick',xLims(1):365/4:xLims(2),'XTickLabelRotation',45,'XtickLabels','');


% loc - 2 
ax(2) = subplot(5,1,2); hold(ax(2),'on'); box(ax(2),'on');  
txt = text(ax(2),0.05,0.8,['(b) ' Locs{2}],'Units','normalized','BackgroundColor','w','Fontsize',10);
fl = fill(ax(2),flt,fly,flc,'HandleVisibility','Off','FaceAlpha',0.5,'EdgeColor',flc);
plot(ax(2),time,model.OP2.invars.Sx,'Color',[0 0 0 ],'DisplayName','Observed');
plot(ax(2),time, model.OP2.pred.Sx_pred,'Color',rr,'DisplayName','Predicted')
plot(ax(2),time, movmean(model.OP2.invars.Sx,[1*24 1*24],'Endpoints','fill'),'Color',ot,'DisplayName','Observed (TA)','LineWidth',1.5)
plot(ax(2),time, movmean(model.OP2.pred.Sx_pred,[1*24 1*24],'Endpoints','fill'),'Color',pt,'DisplayName','Predicted (TA)','LineWidth',1.5)
ylabel(ax(2),'S (PSU)','Interpreter','Latex')
set(ax(2),'Xtick',xLims(1):365/4:xLims(2),'XTickLabelRotation',45,'XtickLabels','');

% loc - 3 
ax(3) = subplot(5,1,3); hold(ax(3),'on'); box(ax(3),'on');  
txt   = text(ax(3),0.05,0.8,['(c) ' Locs{3}],'Units','normalized','BackgroundColor','w','Fontsize',10); 
fl    = fill(ax(3),flt,fly,flc,'HandleVisibility','Off','FaceAlpha',0.5,'EdgeColor',flc);
plot(ax(3),time,model.OP3.invars.Sx,'Color',[0 0 0 ],'DisplayName','Observed');
plot(ax(3),time, model.OP3.pred.Sx_pred,'Color',rr,'DisplayName','Predicted')
plot(ax(3),time, movmean(model.OP3.invars.Sx,[1*24 1*24],'Endpoints','fill'),'Color',ot,'DisplayName','Observed (TA)','LineWidth',1.5)
plot(ax(3),time, movmean(model.OP3.pred.Sx_pred,[1*24 1*24],'Endpoints','fill'),'Color',pt,'DisplayName','Predicted (TA)','LineWidth',1.5)
ylabel(ax(3),'S (PSU)','Interpreter','Latex')
set(ax(3),'Xtick',xLims(1):365/4:xLims(2),'XTickLabelRotation',45,'XtickLabels','');

% loc - 4
ax(4) = subplot(5,1,4); hold(ax(4),'on'); box(ax(4),'on');  
txt   = text(ax(4),0.05,0.8,['(d) ' Locs{4}],'Units','normalized','BackgroundColor','w','Fontsize',10);
fl    = fill(ax(4),flt,fly,flc,'HandleVisibility','Off','FaceAlpha',0.5,'EdgeColor',flc);
plot(ax(4),time,model.OP4.invars.Sx,'Color',[0 0 0 ],'DisplayName','Observed');
plot(ax(4),time, model.OP4.pred.Sx_pred,'Color',rr,'DisplayName','Predicted')
plot(ax(4),time, movmean(model.OP4.invars.Sx,[1*24 1*24],'Endpoints','fill'),'Color',ot,'DisplayName','Observed (TA)','LineWidth',1.5)
plot(ax(4),time, movmean(model.OP4.pred.Sx_pred,[1*24 1*24],'Endpoints','fill'),'Color',pt,'DisplayName','Predicted (TA)','LineWidth',1.5)
ylabel(ax(4),'S (PSU)','Interpreter','Latex')
set(ax(4),'Xtick',xLims(1):365/4:xLims(2),'XTickLabelRotation',45,'XtickLabels','');

% residuals
ax(5)   = subplot(5,1,5); hold(ax(5),'on'); box(ax(5),'on');  
Colors  = gray(5);
txt     = text(ax(5),0.05,0.8,['(e) '],'Units','normalized','BackgroundColor','w','Fontsize',10);
for ii = 1:4
res  = eval(['model.OP' num2str(ii) '.invars.Sx' ])-eval(['model.OP' num2str(ii) '.pred.Sx_pred' ]);
plot(ax(5),time,res + Offsets(ii) ,'Color',Colors(ii,:),'DisplayName',[Locs{ii} ' + ' num2str(Offsets(ii))]) 
end
ylabel(ax(5),'Residual (PSU)','Interpreter','Latex') 
set(ax(5),'Xtick',xLims(1):365/4:xLims(2),'XTickLabelRotation',45,'XtickLabels','');
datetick(ax(5),'x','mmm-YYYY','Keeplimits','Keepticks')
lgd2 = legend(ax(5),'Location', 'North','Orientation','Horizontal')
ylim(ax,[0 ylm]);
xlim(ax,[xLims(1) xLims(2)]);
ax(5).TickLabelInterpreter = 'latex';
lgd1.Position  = [0.1741    0.93    0.6866    0.025];
lgd2.Position  = [0.1741    0.24    0.6866    0.025];

if PRINT 
saveas(gcf,[save_dir filesep 'subfig02'  '.pdf']);
close(gcf);
end 


