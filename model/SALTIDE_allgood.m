%% Check all input
function [Optdata] = SALTIDE_allgood(gpt,Optdata)
% Returns a logical vector with the data point where all needed data is available 
%% Check fields
Fields  = fields (Optdata.invars);
gp      = NaN(length(Optdata.invars.time),length(Fields));
for ii = 1:length(Fields)  
    gp(:,ii) =  ~isnan(Optdata.invars.(Fields{ii}));
end 
gp      = all(gp,2);

%%
Optdata.prop.pc      = (Optdata.invars.time < Optdata.invars.time_cal_end);   % point used for calibration

Optdata.prop.gp      = (gp & Optdata.prop.pc);    
Optdata.prop.gpt     = (gp & gpt & Optdata.prop.pc);    
Optdata.prop.gpv     = gp;                
Optdata.prop.gptv    = (gp & gpt);    

Optdata.prop.nubo        = length(Optdata.prop.gp);           % number of observations
Optdata.prop.nubo_gp     = sum(Optdata.prop.gp);              % number of good point observations
Optdata.prop.nubo_nc     = sum(Optdata.prop.gpt);             % number of non clipped observations

Optdata.prop.nubo_perc    = sum(Optdata.prop.gp)/length(Optdata.prop.gp);      % percentage of good point observations 
Optdata.prop.nubo_nc_perc = sum(Optdata.prop.gpt)/length(Optdata.prop.gpt);    % percentage of good point non clipped observations
end 