function Optdata = SALTIDE_Optimize(Optdata)

%% Define input
gp   = Optdata.prop.gp;  % good point
gpt  = Optdata.prop.gpt; % good point truncked 
K    = Optdata.prop.K; 
dt   = Optdata.prop.dt; 

time = Optdata.invars.time;  
Sx   = Optdata.invars.Sx;  
S0   = Optdata.invars.S0;
Sr   = Optdata.invars.Sr; 
Qr   = Optdata.invars.Qr;
hs   = Optdata.invars.hs;
n0   = Optdata.invars.n0;
dRho = Optdata.invars.dRho;
% 
% %Sx   = movmean(Sx,[24 24],'omitnan')
% dQr             = zeros(size(Qr)); 
% dQr(24:end)     = Qr(24:end)- Qr(1:end-23);
% dQr(~(isnan(Qr) == isnan(dQr))) = 0;

SxS0              = (Sx-Sr)./(S0-Sr); 
SxS0(SxS0<0)      = 0; 
DxD0              = NaN(size(Sx)); 

%% Define freq update functions
Optdata          = SALTIDE_ini_ha(Optdata);
freq             = @(x) SALTIDE_FreqRy(Optdata,SALTIDE_Ry(x,Optdata));
wt               = 2*pi/(Optdata.surgelevels.plugh.T*3600*24);

if      strcmp(Optdata.power,'PV') % Power-Variable
    D0                = @(x,Qr,dRho,n0,p)   (dRho(p).^x(1) .* (Qr(p)./(n0(p).^3.*wt)).^x(1)).*(n0(p).^2.*wt);  
elseif  strcmp(Optdata.power,'PT') % Power-Theory
    D0                = @(x,Qr,dRho,n0,p)   (dRho(p).^0.57 .* (Qr(p)./(n0(p).^3.*wt)).^0.57).*(n0(p).^2.*wt); 
elseif  strcmp(Optdata.power,'PC') % Power-Coupled   
    D0                = @(x,Qr,dRho,n0,p)   (dRho(p).^x(2) .* (Qr(p)./(n0(p).^3.*wt)).^x(2)).*(n0(p).^2.*wt); 
end
%% 
% Set model 
if strcmp(Optdata.model,'Q') % Discharge model 
    tc      = @(x,time,freqin,p) (x(2).*Qr(p)./D0(x,Qr,dRho,n0,p)).* [ones(size(hs(p))) cos(2*pi*freqin'.*time(p))  sin(2*pi*freqin'.*time(p))];    %Qr(p).^(x(3)).*cos(2*pi*freqin'.*time(p))  Qr(p).^(x(3)).*sin(2*pi*freqin'.*time(p))        
elseif  strcmp(Optdata.model,'QH') % Stage model
    tc      = @(x,time,freqin,p) (x(2).*Qr(p)./D0(x,Qr,dRho,n0,p)).* [ones(size(hs(p))) hs(p) cos(2*pi*freqin'.*time(p))  sin(2*pi*freqin'.*time(p)) hs(p).*cos(2*pi*freqin'.*time(p))  hs(p).*sin(2*pi*freqin'.*time(p))];
%    tc      = @(x,time,freqin,p) [(x(2).*dQr(p)./D0(x,Qr,dRho,n0,p)).* ones(size(hs(p))) (x(2).*Qr(p)./D0(x,Qr,dRho,n0,p)).* [ones(size(hs(p))) hs(p) cos(2*pi*freqin'.*time(p))  sin(2*pi*freqin'.*time(p)) hs(p).*cos(2*pi*freqin'.*time(p))  hs(p).*sin(2*pi*freqin'.*time(p))]];

elseif  strcmp(Optdata.model,'QHC') % model including a constant (or) negative backround disperison
    tc      = @(x,time,freqin,p) [(1./D0(x,Qr,dRho,n0,p)).*[ones(size(hs(p))) hs(p)]   (x(2).*Qr(p)./D0(x,Qr,dRho,n0,p)).* [ones(size(hs(p))) hs(p)]      (1./D0(x,Qr,dRho,n0,p)).*[cos(2*pi*freqin'.*time(p))  sin(2*pi*freqin'.*time(p))]    (x(2).*Qr(p)./D0(x,Qr,dRho,n0,p)).* [ cos(2*pi*freqin'.*time(p))  sin(2*pi*freqin'.*time(p)) hs(p).*cos(2*pi*freqin'.*time(p))  hs(p).*sin(2*pi*freqin'.*time(p))]];
end 

% called functions when using fmincon to find best set of powers. 
% cfs         = @(x,time,freqin,Dx_in,p)  tc(x,time,freqin,p)\Dx_in(p);
% DxD0_pr     = @(x,t,Dx_in,gp,gpt)       tc(x,time,freq(x),gp)*cfs(x,time,freq(x),Dx_in,gpt);  % for cfs use gpt (good point trunced)
% SxS0_pr     = @(x,time,Dx_in,gp,gpt)    (SALTIDE_Trunck(DxD0_pr(x,time,Dx_in,gp,gpt))+1).^(1/x(2)); % 
% sse_f       = @(x)                      SALTIDE_SSE(SxS0_pr(x,time,SALTIDE_Sx2Dx(Sx,Sr,S0,gpt,x(2)),gp,gpt),SxS0(gp));

% called functions when using lsqcurvefit to optimize the problem
cfs_lsq       = @(x_u,time,freqin,Dx_in,p)  tc(x_u,time,freqin,p)\Dx_in(p);
DxD0_lsq      = @(x_u,time) tc(x_u,time,freq(x_u),gp)*cfs_lsq(x_u,time,freq(x_u),SALTIDE_Sx2Dx(Sx,Sr,S0,gpt,x_u(2)),gpt);
Sx_lsq        = @(x_u,time) ((( SALTIDE_Trunck(DxD0_lsq(x_u,time))+1).^(1/x_u(2))).*(S0(gp)-Sr(gp))+Sr(gp));



%% Optimize parameters x_in
x_in = Optdata.prop.x_in; % inital point for optimalization
x_lb = Optdata.prop.x_lb; % upperbound for optimalization
x_ub = Optdata.prop.x_ub; % lowerbound for optimalization

if isnumeric(K) % fix and set x_in equal to K.
    x_in(2) = K; x_lb(2) = K;  x_ub(2) = K;  
%     options                          = optimoptions(@fmincon,'MaxFunEvals',5000,'Display','off');
%     [x_fn,fval,exitflag,output,lambda,grad,Hessian]      = fmincon(sse_f,x_in,[],[],[],[],x_lb,x_ub,[],options);
    [x_fn,resnorm,R,exitflag,output,lambda,J] ...
           = lsqcurvefit(Sx_lsq,x_in,time,Sx(gp),x_lb,x_ub);
    pCov = inv(J'*J)*((R'*R)./(numel(Sx(gp)-numel(x_fn))));
    conf   = nlparci(x_fn,R,'jacobian',J, 'alpha',0.0460);
    x_std  = diff(conf')/4;
else strcmp(K,'call')
%     options                          = optimoptions(@fmincon,'Display','off');
%     [x_fn,fval,exitflag,output,lambda,grad,Hessian]      = fmincon(sse_f,x_in,[],[],[],[],x_lb,x_ub,[],options);
    [x_fn,resnorm,R,exitflag,output,lambda,J] ...
           = lsqcurvefit(Sx_lsq,x_in,time,Sx(gp),x_lb,x_ub);
    pCov = inv(J'*J)*((R'*R)./(numel(Sx(gp)-numel(x_fn))));
    conf   = nlparci(x_fn,R,'jacobian',J, 'alpha',0.0460);
    x_std  = diff(conf')/4; 
    
    
end 

%% Final coefs using Robustfit
% step 1: gpt for harmonic model
tc_fn           = tc(x_fn,time,freq(x_fn),gpt);
DxD0            = SALTIDE_Sx2Dx(Sx,Sr,S0,gpt,x_fn(2));
[cfs_fn ,STATS] = robustfit(tc_fn,DxD0(gpt),[],[],'off');

% step 2: gp for predictions
tc_fn             = tc(x_fn,time,freq(x_fn),gp);
DxD0_p            = tc_fn*cfs_fn;

% Step 3: predicted singal, risiduals and variance
DxD0_ps         = SALTIDE_Trunck(DxD0_p);
Sx_pred         = ((DxD0_ps+1).^(1/x_fn(2))).*(S0(gp)-Sr(gp))+Sr(gp);
resout          = Sx(gp)-Sx_pred;
varx            = cov(Sx(gp));   
varxr           = cov(resout);
lsqfit          = 100*(varxr/varx);

%% Get final freqs and names
[Ry, Optdata]     = SALTIDE_Ry(x_fn,Optdata);
[freq_Ry,name_Ry] = SALTIDE_FreqRy(Optdata,Ry);
%% Store output 
Optdata.fmin_ha.Pars.freq     = freq_Ry;
Optdata.fmin_ha.Pars.name     = name_Ry;
Optdata.fmin_ha.Pars.tc_fn    = tc_fn;
Optdata.fmin_ha.Pars.cfs      = cfs_fn;
Optdata.fmin_ha.Pars.x        = x_fn;
Optdata.fmin_ha.Pars.x_std    = x_std; 
Optdata.fmin_ha.Pars.pCov     = pCov;
Optdata.fmin_ha.Pars.STATS    = STATS;
Optdata.fmin_ha.fun.D0        = D0; 
Optdata.fmin_ha.fun.tc        = tc;
Optdata.fmin_ha.Out.DxD0_in   = DxD0;
Optdata.fmin_ha.Out.DxD0      = DxD0_p;
Optdata.fmin_ha.Out.Sx        = Sx_pred;
Optdata.fmin_ha.Out.Sr        = Sr;
Optdata.fmin_ha.Out.resout    = resout;  
Optdata.fmin_ha.Out.lsqfit    = lsqfit;
Optdata.fmin_ha.Out.D0        = (x_fn(2)./D0(x_fn,Qr,dRho,n0,gp));  
Optdata.fmin_ha.Out.QrD0      = (x_fn(2).*Qr(gp)./D0(x_fn,Qr,dRho,n0,gp));
Optdata.fmin_ha.Out.QrD0hs    = (x_fn(2).*Qr(gp)./D0(x_fn,Qr,dRho,n0,gp)).*hs(gp);     
%Optdata.fmin_ha.Fmincon.fval  = fval; 
%Optdata.fmin_ha.Fmincon.fval  = exitflag; 
%% Print to cmd
%fprintf('calibration: percent of var residual after lsqfit/var original: %5.2f %%\n',100*(varxr/varx));

end 