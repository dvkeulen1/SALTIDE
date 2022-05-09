%% fig 08
clear all; close all; clc;
%%  Load the model output
modelname = 'eq10_pred';
sub_dir   = 'c:\Users\Daan\Documents\PhD - SALTI\02_Paper_1\01_Data\04_Scripts\SALTIDE\Update_march_2020\';
struc_dir = [sub_dir '\Data_and_experiments\Experiments\'];
save_dir  = [sub_dir 'Data_and_experiments\Figures\'];
load([struc_dir 'eq10_pred.mat']);

PRINT    = 0;
%% Correlation between all parameters
Locs    = {'Emspier','Pogum','Gandersum','Terborg'}
subplt  = 1;
abc     = char(97:122);

init_fig(19,10,8)
for ii = [1 4]; 
clear OP1_corr_ext
tide_name = cellstr(eval([modelname '.OP' num2str(ii) '.sigcon.nameSig'])');
OP1_corr  = eval([modelname '.OP' num2str(ii) '.pred.stats.coeffcorr']);
OP1_covb  = eval([modelname '.OP' num2str(ii) '.pred.stats.covb']);

s_prs   = 2;    % stage pars
h_prs   = size(tide_name,1); % harmonic pars
idx = [];

% restructure matrix to set cosine and sine componentent next to each other
for pp = 1:h_prs
    idx = [idx (s_prs +  pp)  (s_prs + pp + h_prs)]
end
OP1_corr_ext    = zeros(size(OP1_corr(idx,idx))+1);
OP1_covb_ext    = zeros(size(OP1_covb(idx,idx))+1);
OP1_corr_ext(1:size(OP1_corr(idx,idx),1),1:size(OP1_corr(idx,idx),1))   = OP1_corr(idx,idx);
OP1_covb_ext(1:size(OP1_covb(idx,idx),1),1:size(OP1_covb(idx,idx),1))   = OP1_corr(idx,idx);

% Set diagonal components to nan
for rr = 1:h_prs*2   
    for cc  = 1:h_prs*2
        if cc>rr
        OP1_corr_ext(rr,cc) = NaN; 
        end       
    end 
end 
OP1_covb_ext(~isnan(OP1_corr_ext)) = NaN; 
%% make plot
ax(ii) = subplot(1,2,subplt);  axis equal;
plc = pcolor(abs(OP1_corr_ext)); set(plc, 'EdgeColor', 'none');

caxis(ax(ii),[0 0.5])
flipud(colormap(bluewhitered(15)))
box(ax(ii),'on'); grid(ax(ii),'on');
set(gca,'layer','top')
set(ax(ii),'XTick', [2:2:h_prs*2],'XTickLabel',tide_name','fontsize',8,'XTickLabelRotation' , 90)
set(ax(ii),'YTick', [2:2:h_prs*2],'YTickLabel',tide_name','fontsize',8,'YTickLabelRotation' , 0)

txt = text(0.05,0.9,['(' abc(subplt) ')' ' '  Locs{ii}],'Units','normalized','FontSize',12);
clb = colorbar('Location','NorthOutside','FontSize',12); 
clb.Label.String = 'Correlation';
clb.Label.Interpreter= 'latex';
subplt = subplt+1; 

%% calulate duration of clipped momenent 
% relative contribution of each unique dt to time series
time = eval([modelname '.OP' num2str(ii) '.invars.time']);
gpt  = eval([modelname '.OP' num2str(ii) '.prop.gpt']);

% determine amount of uniq counts
dt_c    = [];
dt      = round(diff(time(gpt)),4);
dt_uniq = unique(dt);
for i = 1:length(dt_uniq)
   dt_c(i,1) = sum(dt==dt_uniq(i)); 
end
rel_contri = (dt_c.*dt_uniq)/(time(end))

corrs        = get(ax(ii),'Position');
ax(ii*2)     = axes;
ax(ii*2).Position = [corrs(1)+corrs(3)*0.525    corrs(2)+corrs(2)*1     0.15 0.2];
br = bar(ax(ii*2),flip(dt_uniq),(flip(rel_contri)))
set(br,'FaceColor',[0.5 0.5 0.5],'EdgeColor' ,[0 0 0])
xlim(ax(ii*2),[0 0.6]); xlabel(ax(ii*2),'dt [d]','Fontsize',10,'fontweight','bold') 
ylim(ax(ii*2),[0.01 1]); ylabel(ax(ii*2),'Time $\%$','Fontsize',10,'fontweight','bold') 
set(ax(ii*2),'YScale', 'log')
end 

if PRINT 
saveas(gcf,[save_dir filesep 'fig08' '.pdf']);
close(gcf);
end 

