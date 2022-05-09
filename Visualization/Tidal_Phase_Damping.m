function [e,d,d0] = Tidal_Phase_Damping(convergence,h_mean,chezy,Amp,C0,periods);
%% Constants 
g = 9.81;
%% friction
omega = 2*pi./(periods.*3600.*24); 
alpha = Amp'./h_mean; 
fric  = g./chezy.^2;    

%%
X = fric.*(C0./omega./h_mean).*alpha ; % Friction number
Y = repmat(C0./(omega.*convergence),[size(X,1) 1]);          % Shape number wavelenght/converge length

%%

% Point of critical convergence;
m1   = (36.*X.^2.*(3.*X.^2+8)-8+12.*X.*sqrt(3).*sqrt((X.^2-2).^2.*(27.*X.^2-4))).^(1/3);
yc   = 1./(3.*X).*(m1./2-1+2.*(12.*X.^2+1)./m1); % Point of criticel converge (above standing wave solution holds, below mixed wave solution holds
%%
for jj = 1:size(X,1) 
for ii = 1:size(X,2)
if Y(jj,ii) <= yc(jj,ii)
    m(jj,ii)  = (27*X(jj,ii) + (9-Y(jj,ii).^2).*Y(jj,ii) + 3*sqrt(3).*sqrt(27*X(jj,ii).^2+2*(9-Y(jj,ii).^2).*Y(jj,ii).*X(jj,ii)+8-Y(jj,ii).^2)).^(1/3);
    u(jj,ii)  = sqrt(1./(3.*X(jj,ii)).*(m(jj,ii)-Y(jj,ii)+((Y(jj,ii).^2-6)./m(jj,ii)))); 
    d(jj,ii)  = 0.5.*(Y(jj,ii)-X(jj,ii).*u(jj,ii).^2);
    g(jj,ii)  = sqrt((((X(jj,ii).^2.*u(jj,ii).^4)-Y(jj,ii).^2)./4)+1); %
    e(jj,ii)  = atan(g(jj,ii)./(Y(jj,ii)-d(jj,ii))); 

elseif Y(jj,ii) > yc(jj,ii) 
    d(jj,ii)  = 0.5*(Y(jj,ii)-sqrt(Y(jj,ii).^2-4));
    e(jj,ii)  = 0; 
end
end 
end 

d0 = d./(C0./omega) ;


end 