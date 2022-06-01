%% fig 01
clear all; close all; clc;

sub_dir   = '..';
save_dir  = [sub_dir 'Data_and_experiments\Figures\'];
PRINT     = 1; 
%% Mixed wave solution 
% Dimensionless numbers 
X    = [1:150];
y    = [0.1:0.1:11]';

% Point of critical convergence;
m1   = (36.*X.^2.*(3.*X.^2+8)-8+12.*X.*sqrt(3).*sqrt((X.^2-2).^2.*(27.*X.^2-4))).^(1/3);
ycFX = 1./(3.*X).*(m1./2-1+2.*(12.*X.^2+1)./m1);

% Make matrix corresponding 
ym   = repmat(y,1,length(X));
Xm   = repmat(X,length(y),1);
ycm  = repmat(ycFX,length(y),1);  
ym(~(ym<ycm)) = NaN; 

m   = (27*Xm + (9-ym.^2).*ym + 3*sqrt(3).*sqrt(27*Xm.^2+2*(9-y.^2).*ym.*Xm+8-ym.^2)).^(1/3);
um  = sqrt(1./(3.*Xm).*(m-ym+((ym.^2-6)./m))); 
dm  = 0.5.*(ym-Xm.*um.^2);
gm  = sqrt((((Xm.^2.*um.^4)-ym.^2)./4)+1); 
ephasem = atan(gm./(ym-dm)); 
%% Standing wave solution 
ym      = repmat(y,1,length(X));
ds      = 0.5*(ym-sqrt(ym.^2-4));
ephases = zeros(size(ym)); 
%% Combine Wave solution 
dc = dm;
dc(isnan(dc)) = ds(isnan(dc)); 
ephasec = ephases;
ephasec(~isnan(dm)) = ephasem(~isnan(dm)); 
%% Friction number Ems
T  = 0.1:0.01:10;   % period [d]
w  = 2*pi./T;       % angular freq [d-1]    
g  = 9.81;          % grav

ha = 4;             % av. depth Ems (Gisen)
h0 = 4;             % mouth depth Ems (Gisen)
a  = 19000;         % Channel convergence 

C  = 65;            % Chezy
f  = g/C.^2;        % 

surge_lv   = 1:1:3; % Surge levels     
[e,d,d0]   = Tidal_Phase_Damping(a,ha,C ,surge_lv,sqrt(h0*g),T);
E_surge    = surge_lv'./((ha/a).*((1-d0.*a)./cos(e))); 

%% Figure
init_fig(19,10,8)

ax(1)= subplot(2,2,1); hold(ax(1),'on'); box(ax(1),'on');  
pclr = pcolor(ax(1),Xm,ym,ephasec); pclr.HandleVisibility = 'off'; pclr.EdgeColor = 'none'; pclr.FaceAlpha = 0.9;
clb  = colorbar(ax(1)); clb.Label.String ='\epsilon (rad)'; clb.Location     = 'eastoutside';
caxis([0 0.5*pi]);colormap(bluewhitered);
plot(ax(1),X,ycFX,'r','LineWidth',2,'DisplayName','Critical convergence \gamma_c')
text(ax(1),0.4,0.1,'mixed wave', 'Units', 'Normalized')
text(ax(1),0.4,0.6,'standing wave', 'Units', 'Normalized','Color','w')
text(ax(1),0.05,0.9,'(a)', 'Units', 'Normalized')
xlim(ax(1),[0 150]); ylim(ax(1),[0 10]);
xlabel(ax(1),'X (-)'); ylabel(ax(1),'$\gamma$ (-)')

%
ax(4) = subplot(2,2,3); hold(ax(4),'on'); box(ax(4),'on'); 
pclr = pcolor(ax(4),Xm,ym,dc); pclr.HandleVisibility = 'off'; pclr.EdgeColor = 'none'; pclr.FaceAlpha = 0.9;
clb = colorbar(ax(4)); clb.Label.String ='\delta (-)';clb.Location  = 'eastoutside';
caxis(ax(4),[-2 2]); colormap(bluewhitered);
plot(ax(4),X,ycFX,'r','LineWidth',2,'DisplayName','Critical convergence \gamma_c')
text(ax(4),0.4,0.1,  'mixed wave', 'Units', 'Normalized','Color','w')
text(ax(4),0.4,0.6,   'standing wave', 'Units', 'Normalized')
text(ax(4),0.05,0.9,  '(b)', 'Units', 'Normalized')
xlim(ax(4),[0 150]); ylim(ax(4),[0 10]);
xlabel(ax(4),'X (-)')
ylabel(ax(4),'$\gamma$ (-)')

Colors = linspecer(size(d,1));
ax =  subplot(2,2,4); hold(ax,'on') ; box(ax,'on'); grid(ax,'on');
set( ax, 'XScale' , 'log')
for ii = 1:size(d,1)
    if ii == 1
        semilogx(ax,T,d(ii,:),'LineStyle','-.','Color',Colors(ii,:),'LineWidth',1.5,'HandleVisibility','on','DisplayName','\delta (-)')
        semilogx(ax,T,e(ii,:),'LineStyle','-','Color',Colors(ii,:),'LineWidth',1.5,'HandleVisibility','on','DisplayName','\epsilon (rad)')
    else
        semilogx(ax,T,d(ii,:),'LineStyle','-.','Color',Colors(ii,:),'LineWidth',1.5,'HandleVisibility','off')
        semilogx(ax,T,e(ii,:),'LineStyle','-','Color',Colors(ii,:),'LineWidth',1.5,'HandleVisibility','off') 
    end
end
text(ax,0.05,0.9,  '(c)', 'Units', 'Normalized')
xlabel(ax,'T (d)'); ylabel(ax,'$\epsilon$ (rad), $\delta$ (-)')
legend(ax,'Location','NorthEast')

ax =  subplot(2,2,2); hold(ax,'on'); box(ax,'on'); grid(ax,'on');
set( ax, 'XScale' , 'log')
for ii = 1:size(d,1)
semilogx(ax,T,E_surge(ii,:)./1000,'LineStyle','-','Color',Colors(ii,:),'LineWidth',1.5,'DisplayName', ['\eta = ' num2str(surge_lv(ii),2)])
end 
text(ax,0.05,0.9,  '(d)', 'Units', 'Normalized')
xlabel(ax,'T(d)'); ylabel(ax,'E (km)')
legend(ax,'Location','NorthEast')
%%

if PRINT 
saveas(gcf,[save_dir filesep 'fig01'  '.pdf']);
close(gcf);
end 
