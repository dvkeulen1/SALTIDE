function [Optdata]= SALTIDE(time,Sx,Qr,h0,varargin)

% Write proper discription of the model..


% input variable
% Qr    = River discharge
% Sf    = Salinity river, Default = 0   
% S0    = Salinity Sea boundary, Default = 34
% Sx    = Salinity record in estuary
% Zetha = Water level time series (ht or vt)
% Tup   = Max surge period
% K     = Van de Burg constant

% Time  series of frequency..  
% sfrq  = Sample frequency [1/d] 

%%
default_type     = 'calibrate'; 
expectedType     = {'calibrate','validate','predict'};

default_model    = 'Q'; 
expectedModel    = {'Q','QH','QHC'};

default_power    = 'PV'; 
expectedpower    = {'PV','PT','PC'};

default_K       = 0.5; % []

default_Sr      = 0;   % psu
default_S0      = 35;  % psu
default_Offset  = 0;   % constant offset to correct salinity station 

default_Tc      = 15;           % C, Reference temperature salinity 
default_Twin    = [1.2 14];     % days
default_sfrq    = 24;           % sample per day 
default_dsigma  = 0.15;         % parameter n from NS-tide
default_Vtime   = NaN;          % Validate time

% signif. testing
default_cases   = 100; 


% calibration parameters For P and K
default_x_in = [0.57 0.5];  
default_x_lb = [0.05  0.05];
default_x_ub = [1 1];

Parser   = inputParser;
%% required input 
addRequired(Parser,'time',@isnumeric );
addRequired(Parser,'Sx',@isnumeric );
addRequired(Parser,'Qr',@isnumeric);
addRequired(Parser,'h0',@isnumeric);

%% Add optional data 
addParameter(Parser,'type',default_type,@(x) any(validatestring(x,expectedType )));
addParameter(Parser,'model',default_model,@(x) any(validatestring(x,expectedModel )));
addParameter(Parser,'power',default_power,@(x) any(validatestring(x,expectedpower )));

addParameter(Parser,'K' ,default_K, @(x) (isnumeric(x) || ischar(x)))
addParameter(Parser,'Sr',default_Sr,@isnumeric)
addParameter(Parser,'S0',default_S0,@isnumeric)

addParameter(Parser,'Tc',default_Tc,@isnumeric)
addParameter(Parser,'Twin',default_Twin,@isnumeric)
addParameter(Parser,'SampleFreq', default_sfrq,@isnumeric)
addParameter(Parser,'dsigma', default_dsigma,@isnumeric)
addParameter(Parser,'Offset',default_Offset,@isnumeric)
addParameter(Parser,'Vali_time',default_Vtime,@isnumeric)
addParameter(Parser,'CasesConSig',default_cases,@isnumeric)

addParameter(Parser,'x_in', default_x_in,@isnumeric)
addParameter(Parser,'x_lb', default_x_lb,@isnumeric)
addParameter(Parser,'x_ub', default_x_ub,@isnumeric)

%% Print the Parse output back to CMD 
Parser.KeepUnmatched = true;
parse(Parser,time,Sx,Qr,h0,varargin{:});

if ~isempty(Parser.UsingDefaults)
   disp('Using defaults: ')
   disp(Parser.UsingDefaults')
end

%% Variable input
if ~all(contains(Parser.UsingDefaults,'S0'))
    S0 = Parser.Results.S0.*ones(size(time)); 
end
if ~all(contains(Parser.UsingDefaults,'Sr'))
    Sr = Parser.Results.Sr.*ones(size(time)); 
end
%% Step1 prepare data  
Optdata.type  = Parser.Results.type; 
Optdata.model = Parser.Results.model; 
Optdata.power = Parser.Results.power; 
Optdata.surgelevels.Twin = Parser.Results.Twin; 

%%

[ids, ~]  = find(~isnan(Sx), 1, 'first'); % first salinity observation
[ide, ~]  = find(~isnan(Sx), 1, 'last');  % last salinity observation

time    = time(ids:ide); Sx      = Sx(ids:ide);  Sr      = Sr(ids:ide); 
S0      = S0(ids:ide);  Qr      = Qr(ids:ide); h0      = h0(ids:ide); 

sfrq    =  Parser.Results.SampleFreq; 
dt      = 1/sfrq;                % delta time 
nstp    = [0:length(time)-1];    % number of steps
time    = (nstp./sfrq)';         % time 

if isnan(Parser.Results.Vali_time)
    time_cal_end =  time(end);
else
    time_cal_end = (Parser.Results.Vali_time-Parser.Results.time(1));
end 
    
%% Step1 get indirect data 
[~,n0]                = SALTIDE_AmpAndRange(h0,sfrq);   
dRho                  = SALTIDE_dRho(S0,Sr,Parser.Results.Tc);           % 
[hsm,ha,Optdata]      = SALTIDE_surgelevels(h0,Sx,time,sfrq,Optdata);
[Qrlag Optdata]       = SALTIDE_Qlag(Qr,h0,sfrq,Optdata);             % find time lag in the data. 
[Sxc,Sr,pp,sfit]      = SALTIDE_SxSr_clip(Sx,Sr,Qr,time,Parser.Results.Offset,Optdata);  % Add the offset

%%  prepare data  
Optdata.invars.time = time; 
Optdata.invars.Sx   = Sx; 
Optdata.invars.S0   = S0; 
Optdata.invars.Sr   = Sr;
Optdata.invars.Qr   = Qrlag; 
Optdata.invars.n0   = n0;
Optdata.invars.hs   = hsm; 
Optdata.invars.dRho = dRho; 
Optdata.invars.time_cal_end = time_cal_end;

Optdata.prop.dt   = dt; 
Optdata.prop.n    = Parser.Results.dsigma;   
Optdata.prop.K    = Parser.Results.K;   
Optdata.prop.x_in = Parser.Results.x_in;  
Optdata.prop.x_lb = Parser.Results.x_lb; 
Optdata.prop.x_ub = Parser.Results.x_ub; 

Optdata   = SALTIDE_allgood(pp,Optdata);
%% Optimize the regression models
[Optdata]     = SALTIDE_Optimize(Optdata);

%% Significant testing 
cfs      = Optdata.fmin_ha.Pars.cfs;
sigma    = Optdata.fmin_ha.Pars.STATS.covb;
cases    = Parser.Results.CasesConSig;
cfs_dis  = SALTIDE_whitenoise(cfs,sigma,cases); 
Optdata  = SALTIDE_sigcon(cfs_dis,Optdata);

%% SALTIDE_PREDICT  

Optdata = SALTIDE_pred(Optdata);

%% Alias testing
[Optdata] = SALTIDE_Rsqr_list(Optdata); 

end



