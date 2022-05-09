%% fig 07
clear all; close all; clc;
%%  Load the model output
sub_dir   = 'c:\Users\Daan\Documents\PhD - SALTI\02_Paper_1\01_Data\04_Scripts\SALTIDE\Update_march_2020\';
struc_dir = [sub_dir '\Data_and_experiments\Experiments\'];
save_dir  = [sub_dir 'Data_and_experiments\Figures\'];

PRINT = 0
%%
Struc_dir2 = [sub_dir '\Data_and_experiments\Data\'];
load([Struc_dir2 'data_ems_river.mat']);
%% load models
%              {P variable and K fixed, P theoratical and K variable, pouwers coupled P is K, en both variable}
namemodel    = {'eq10_cal_P_var_K_fix','eq10_cal_P_theo_K_var','eq10_cal_PisK_var','eq10_cal_PK_var'};
submdls      = 1:4;

for rr = 1:length(namemodel)
    load([struc_dir namemodel{rr} '.mat']);
end
%%
Colors      = linspecer(length(namemodel));
Markers     = ['s','o','o','d','d','^','h'];
X           = 50.9 - [41.2,35.3,31.7,24.5]; % relative to Knock


%% Development of fitted powers 
init_fig(19,10,8)
%  id_2 = find(contains(namemodel,namemodel{mm}))

% Panel 1
ax(1) = subplot(2,3,1) ;  hold(ax(1),'on'); box(ax(1),'on'); text(0.05,0.9,'(a)','Units','normalized');
for mm = 1:length(namemodel)
    for ss = submdls
        if strcmp(eval([namemodel{mm} '.OP' num2str(submdls(ss)) '.power']), 'PC' )
            x1(ss) = eval([namemodel{mm} '.OP' num2str(submdls(ss)) '.fmin_ha.Pars.x(2)' ]);
        else 
            x1(ss) = eval([namemodel{mm} '.OP' num2str(submdls(ss)) '.fmin_ha.Pars.x(1)' ]);
        end
    end 
    plot(ax(1),X,x1,'LineWidth',1,'Color',Colors(mm,:),'Marker',Markers(mm),'MarkerFaceColor',Colors(mm,:),  'MarkerEdgeColor','k','MarkerSize',5)
end
ylim(ax(1),[0 1]); xlim(ax(1),[0 30]);ylabel('$P$ (-)', 'Interpreter','latex'); 

% Panel 2
ax(2)       = subplot(2,3,2) ;  hold(ax(2),'on'); box(ax(2),'on'); text(0.05,0.9,'(b)','Units','normalized');
for mm = 1:length(namemodel)
    for ss = submdls
        x2(ss) = eval([namemodel{mm} '.OP' num2str(submdls(ss)) '.fmin_ha.Pars.x(2)' ]);
    end
    plot(ax(2),X,x2,'LineWidth',1,'Color',Colors(mm,:),'Marker',Markers(mm),'MarkerFaceColor',Colors(mm,:),  'MarkerEdgeColor','k','MarkerSize',5)
end
ylim(ax(2),[0 1]);   xlim(ax(2),[0 30]); ylabel('$K$ (-)', 'Interpreter','latex', 'Interpreter','latex');

% Panel 3
ax(3) = subplot(2,3,3) ;  hold(ax(3),'on'); box(ax(3),'on'); text(0.05,0.9,'(c)','Units','normalized');
for mm = 1:length(namemodel)
    for ss = submdls
        x3(ss) = eval([namemodel{mm} '.OP' num2str(submdls(ss)) '.pred.lsqfit' ]);
    end
    plot(ax(3),X,x3,'LineWidth',1,'Color',Colors(mm,:),'Marker',Markers(mm),'MarkerFaceColor',Colors(mm,:),  'MarkerEdgeColor','k','MarkerSize',5)
end
ylim(ax(3),[0 30]);  xlim(ax(3),[0 30]);  
ylabel('($\%$)', 'Interpreter','latex', 'Interpreter','latex');
legend(ax(3),{ 'K = 0.5','P = 0.57','P = K','P - K cal'},'Location','NorthEast', 'Interpreter','latex', 'Interpreter','latex')

% Panel 4
ax(4) = subplot(2,3,4) ;  hold(ax(4),'on'); box(ax(4),'on'); text(0.05,0.9,'(d)','Units','normalized');
for mm = 1:length(namemodel)
    for ss = submdls
        x1(ss) = eval([namemodel{mm} '.OP' num2str(submdls(ss)) '.pred.cfs(1)' ]);
    end
    plot(ax(4),X,x1,'DisplayName',namemodel{mm},'LineWidth',1,'Color',Colors(mm,:),'Marker',Markers(mm),'MarkerFaceColor',Colors(mm,:),  'MarkerEdgeColor','k','MarkerSize',5)

 end
ylim(ax(4),[-0.002 0 ]);  ylabel('a$_0$ (m$^{-1}$)'); xlabel('km from Knock');

% Panel 5
ax(5) = subplot(2,3,5) ;  hold(ax(5),'on'); box(ax(5),'on'); text(0.05,0.9,'(e)','Units','normalized');
for mm = 1:length(namemodel)
    for ss = submdls
        x1(ss) = eval([namemodel{mm} '.OP' num2str(submdls(ss)) '.pred.cfs(2)' ]);
    end
    plot(ax(5),X,-x1,'DisplayName',namemodel{mm},'LineWidth',1,'Color',Colors(mm,:),'Marker',Markers(mm),'MarkerFaceColor',Colors(mm,:),  'MarkerEdgeColor','k','MarkerSize',5)

end
ylim(ax(5),[-0.0005 0 ]);  ylabel('a$_1$ (m$^{-1}$)'); xlabel('km from Knock')

% Panel 6
ax(6) = subplot(2,3,6) ;  hold(ax(6),'on'); box(ax(6),'on'); text(0.05,0.9,'(f)','Units','normalized')
for mm = 1:length(namemodel)
    for ss = submdls  
        cfs       = eval([namemodel{mm} '.OP' num2str(submdls(ss)) '.pred.cfs' ]) ; 
        tide_name = cellstr(eval([namemodel{mm} '.OP' num2str(submdls(ss)) '.fmin_ha.Pars.name' ]));
        tide_sigc = (eval([namemodel{mm} '.OP' num2str(submdls(ss)) '.sigcon.sigcon' ]));
        tide_name = tide_name(logical(tide_sigc));

        s_prs = 2;
        h_prs = size(tide_name,1);
        idm2 = find(ismember(tide_name,'M2'));

        idx  = [idm2+[0 h_prs 2*h_prs 3*h_prs]] +s_prs;

        a21(ss) = cfs(idx(1));
        a22(ss) = cfs(idx(2));
    end
  
    plot(ax(6),X,a21,'DisplayName',namemodel{mm},'LineStyle','-','LineWidth',1,'Color',Colors(mm,:),'Marker',Markers(mm),'MarkerFaceColor',Colors(mm,:),  'MarkerEdgeColor','k','MarkerSize',5)
    plot(ax(6),X,a22,'DisplayName',namemodel{mm},'LineStyle','-.','LineWidth',1,'Color',Colors(mm,:),'Marker',Markers(mm),'MarkerFaceColor',Colors(mm,:),  'MarkerEdgeColor','k','MarkerSize',5)
end

ylabel('a$_{2,i}$ (m$^{-1}$)')
ylim(ax(6),[-0.001 0.001 ]);  
xlabel('km from Knock')

if PRINT 
saveas(gcf,[save_dir filesep 'fig07'  '.pdf']);
close(gcf);
end 


