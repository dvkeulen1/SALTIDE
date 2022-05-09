function [Optdata] = SALTIDE_pred(Optdata)
gp   = Optdata.prop.gp;  % good point
gpt  = Optdata.prop.gpt;  
gpv  = Optdata.prop.gpv;  % good point validate
gptv = Optdata.prop.gptv;

time = Optdata.invars.time;  
Sx   = Optdata.invars.Sx;  
S0   = Optdata.invars.S0;
Sr   = Optdata.invars.Sr; 
Qr   = Optdata.invars.Qr;
hs   = Optdata.invars.hs;
n0   = Optdata.invars.n0;
dRho = Optdata.invars.dRho;

SxS0              = (Sx-Sr)./(S0-Sr); 
SxS0(SxS0<0)      = 0; 
DxD0              = NaN(size(Sx)); 
DxD0_pred         = NaN(size(Sx)); 
Sx_pred           = NaN(size(Sx)); 

%% load Desing matrix function, Optimized powers, D0 function and significant freqs. 
tc          = Optdata.fmin_ha.fun.tc; % @(x,time,freqin,p)
D0f         = Optdata.fmin_ha.fun.D0; % @(x,Qr,dRho,no,p)
freq        = Optdata.sigcon.freqs_sig; 
x           = Optdata.fmin_ha.Pars.x;

% step 1: gpt for harmonic model    
DxD0        = SALTIDE_Sx2Dx(Sx,Sr,S0,gpt,x(2)); % 
tc_fn       = tc(x,time,freq,gpt);
[cfs,STATS] = robustfit(tc_fn,DxD0(gpt),[],[],'off');

% step 2: gpv for the predictions
tc_fn           = tc(x,time,freq,gpv);
DxD0_pred(gpv)  = tc_fn*cfs;
DxD0_pred       = SALTIDE_Trunck(DxD0_pred);
Sx_pred(gpv)    = ((DxD0_pred(gpv)+1).^(1/x(2))).*(S0(gpv)-Sr(gpv))+Sr(gpv);


%%  Direct stats model performance
% Stats entire period
resout      = zeros(size(Sx));
resout(gpv) = Sx_pred(gpv) - Sx(gpv);
varx        = cov(Sx(gpv));   
varxr       = cov(resout(gpv));
lsqfit      = 100*(varxr/varx);
rmse        = sqrt(sum((Sx_pred(gpv) - Sx(gpv)).^2)./(length(Sx((gpv)))-2));
bias        = mean(Sx((gpv))-Sx_pred((gpv)));

% call period
varx_cal    = cov(Sx(gp));   
varxr_cal   = cov(resout(gp));
lsqfit_cal  = 100*(varxr_cal/varx_cal);
rmse_cal    = sqrt(sum((Sx_pred(gp)  - Sx(gp)).^2)./(length(Sx(gp))-2));
bias_cal    = mean(Sx(gp)-Sx_pred(gp));

% vall period
varx_val     = cov(Sx(gpv &~gp));   
varxr_val    = cov(resout(gpv &~gp));
lsqfit_val   = 100*(varxr_val/varx_val);
rmse_val     = sqrt(sum(((Sx_pred(gpv &~gp)  - Sx(gpv &~gp)).^2)./(length(Sx(gpv &~gp))-2)));
bias_val     = mean(Sx(gpv &~gp)-(Sx_pred(gpv &~gp)));


%% Get final amplitudes (1) and reconstruct signals (2). 
cst_stage_QD0    = NaN (size(Sx)); 
chst_stage_invD0 = NaN (size(Sx)); 
cst_surge_QD0    = NaN (size(Sx)); 
cst_surge_invD0  = NaN (size(Sx)); 
cst_tide_QD0     = NaN (size(Sx)); 
cst_tide_invD0   = NaN (size(Sx)); 
D0               = NaN (size(Sx)); 
QrD0             = NaN (size(Sx)); 
QrD0hs           = NaN (size(Sx)); 

D0(gpv)        = (x(2)./D0f(x,Qr,dRho,n0,gpv));  
QrD0(gpv)      = (x(2).*Qr(gpv)./D0f(x,Qr,dRho,n0,gpv));
QrD0hs(gpv)    = (x(2).*Qr(gpv)./D0f(x,Qr,dRho,n0,gpv)).*hs(gpv); 

nr_fr     = length(freq);        
amp       = NaN ([length(Sx),nr_fr ]); 
phase     = NaN ([length(Sx),nr_fr ]); 

if strcmp(Optdata.model,'Q') % Discharge model      
        nr_st = 1;
        cst_stage_QD0(gpv)    = tc_fn(:,1)*cfs(1); 
        cst_tide_QD0(gpv)     = tc_fn(:,nr_st+1:end)*cfs(nr_st+1:end);  
        
        dc2   =  cfs(nr_st+1:nr_st+nr_fr);             % cosine parts
        ds2   =  cfs(nr_st+nr_fr+1:nr_st+nr_fr*2);     % sine parts     
        
        Ak    =  sqrt(dc2.^2 + ds2.^2)' .*QrD0(gpv);   % nubo x cases
        ak    =  (atan2(ds2,dc2))';                                   % 1 x cases
        
        aplus = ((Ak.*cos(ak)) - 1i*((Ak.*sin(ak))))/2;            % 
        amin  = ((Ak.*cos(ak)) + 1i*((Ak.*sin(ak))))/2;            %
        
        amp(gpv,:)       = abs(aplus)+abs(amin);       %
        phase(gpv,:)     = angle(amin)*180/pi;         %
         
elseif  strcmp(Optdata.model,'QH') % Stage model
        nr_st = 2;
           
        cst_stage_QD0(gpv)    = tc_fn(:,1)*cfs(1); 
        cst_surge_QD0(gpv)    = tc_fn(:,2)*cfs(2); 
        cst_tide_QD0(gpv)     = tc_fn(:,nr_st+1:end)*cfs(nr_st+1:end); 
    
        dc2  =  cfs(nr_st+1:nr_st+nr_fr);             % cosine parts
        ds2  =  cfs(nr_st+nr_fr+1:nr_st+nr_fr*2);     % sine parts
        dc3  =  cfs(nr_st+nr_fr*2+1:nr_st+nr_fr*3);   % cosine parts
        ds3  =  cfs(nr_st+nr_fr*3+1:nr_st+nr_fr*4);   % sine parts

        Ak   =  sqrt(dc2.^2 + ds2.^2)' .*QrD0(gpv);   % nubo x cases
        Bk   =  sqrt(dc3.^2 + ds3.^2)' .*QrD0hs(gpv); % nubo x cases
        ak   =  (atan2(ds2,dc2))';                                   % 1 x cases
        bk   =  (atan2(ds3,dc3))';                                   % 1 x cases

        aplus   = ((Ak.*cos(ak)+Bk.*cos(bk)) - 1i*((Ak.*sin(ak)+Bk.*sin(bk))))/2;            % plus     (dc - 1i ds)
        amin    = ((Ak.*cos(ak)+Bk.*cos(bk)) + 1i*((Ak.*sin(ak)+Bk.*sin(bk))))/2;            % amp min  (dc - 1i ds)        
       
        amp(gpv,:)   = abs(aplus)+abs(amin);       % A13...
        phase(gpv,:) = angle(amin)*180/pi;  
   
elseif  strcmp(Optdata.model,'QHC') % Stage model
        nr_st = 4; 
             
        chst_stage_invD0(gpv) = tc_fn(:,1)*cfs(1);
        cst_stage_QD0(gpv)    = tc_fn(:,3)*cfs(3); 
        cst_surge_invD0(gpv)  = tc_fn(:,2)*cfs(2); 
        cst_surge_QD0(gpv)    = tc_fn(:,4)*cfs(4);
        cst_tide_invD0(gpv)   = tc_fn(:,nr_st+1:nr_st+nr_fr*2)*cfs(nr_st+1:nr_st+nr_fr*2); 
        cst_tide_QD0(gpv)     = tc_fn(:,nr_st+nr_fr*2+1:end)*cfs(nr_st+nr_fr*2+1:end); 
         
        dc1  =  cfs(nr_st+1:nr_st+nr_fr);             % cosine parts
        dc2  =  cfs(nr_st+nr_fr*2+1:nr_st+nr_fr*3);   % cosine parts
        dc3  =  cfs(nr_st+nr_fr*4+1:nr_st+nr_fr*5);   % cosine parts
        ds1  =  cfs(nr_st+nr_fr+1:nr_st+nr_fr*2);     % sine parts           
        ds2  =  cfs(nr_st+nr_fr*3+1:nr_st+nr_fr*4);   % sine parts
        ds3  =  cfs(nr_st+nr_fr*5+1:nr_st+nr_fr*6);   % sine parts
         
        Ak   =  sqrt(dc1.^2 + ds1.^2)' .*D0(gpv);
        Bk   =  sqrt(dc2.^2 + ds2.^2)' .*QrD0(gpv);   % nubo x cases
        Ck   =  sqrt(dc3.^2 + ds3.^2)' .*QrD0hs(gpv); % nubo x cases
        ak   =  (atan2(ds1,dc1))';                                   % 1 x cases
        bk   =  (atan2(ds2,dc2))';                                   % 1 x cases
        ck   =  (atan2(ds3,dc3))';                                   % 1 x cases

        aplus   = ((Ak.*cos(ak)+Bk.*cos(bk)+Ck.*cos(ck)) - 1i*((Ak.*sin(ak)+Bk.*sin(bk)+Ck.*sin(ck))))/2;            % plus     (dc - 1i ds)
        amin    = ((Ak.*cos(ak)+Bk.*cos(bk)+Ck.*cos(ck)) + 1i*((Ak.*sin(ak)+Bk.*sin(bk)+Ck.*sin(ck))))/2;            % amp min  (dc - 1i ds)        

        amp(gpv,:)       = abs(aplus)+abs(amin);       % A13...
        phase(gpv,:)     = angle(amin)*180/pi;    
end

%% Save all the data
Optdata.pred.DxD0    = DxD0;
Optdata.pred.SxS0    = SxS0;
Optdata.pred.DxD0_pr = DxD0_pred;
Optdata.pred.Sx_pred = Sx_pred; 

Optdata.pred.K_D0        = Optdata.fmin_ha.Out.D0;
Optdata.pred.KQr_D0      = Optdata.fmin_ha.Out.QrD0;
Optdata.pred.KQrhs_D0    = QrD0hs; 

Optdata.pred.cst_stage_QD0    = cst_stage_QD0 ; 
Optdata.pred.chst_stage_invD0 = chst_stage_invD0 ; 
Optdata.pred.cst_surge_QD0    = cst_surge_QD0 ; 
Optdata.pred.cst_surge_invD0  = cst_surge_invD0 ; 
Optdata.pred.cst_tide_QD0     = cst_tide_QD0; 
Optdata.pred.cst_tide_invD0   = cst_tide_invD0; 

Optdata.pred.cfs              = cfs;
Optdata.pred.stats            = STATS;
Optdata.pred.amp              = amp;
Optdata.pred.phase            = phase; 
Optdata.pred.freq             = freq; 
Optdata.pred.namefreq         = Optdata.sigcon.nameSig'; 
    
Optdata.pred.lsqfit     = lsqfit;
Optdata.pred.lsqfit_cal = lsqfit_cal;
Optdata.pred.lsqfit_val = lsqfit_val;
Optdata.pred.rmse       = rmse;
Optdata.pred.rmse_cal   = rmse_cal;
Optdata.pred.rmse_val   = rmse_val;
Optdata.pred.bias       = bias;       
Optdata.pred.bias_cal   = bias_cal;
Optdata.pred.bias_val   = bias_val;
%%
fprintf('percent of var residual after lsqfit/var original: %5.2f %%\n',lsqfit);

end 
