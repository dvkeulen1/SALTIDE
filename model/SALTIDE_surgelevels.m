function [hsm,ha,Optdata] = SALTIDE_surgelevels(h0,Sx,time,sfrq,Optdata)
%SALTIDE_surgelevel makes an estimates of the strom-surge variariations 
%                   from the water level variations
%
%   This function first performs a harmonic analysis (t-tide), the
%   risiduals are assumed to be atmospherically forced and subsequently low
%   and high passed filtered.  
%
%   Syntax:
%   hs,ha,tidestruc] = SALTIDE_surgelevel(h0,Sx,time,sfrq)
%
%   Input: 
%   h0        = timeseries of the water level elevations at the mouth
%   Sx        = timeseries of salinity measured in a estuary
%   time      = timeseries
%   sfrq      = sample frequency 
%
%   Output:
%   hs        =  estimate of the storm-surge variations
%   ha        =  tidal signal (product t-tide)
%   tidestruc =  info from t-tide (product t-tide)
%% Settings/Opts
warning('off','all')
%% %calculate ha astronomical
[tidestruc,ha]=t_tide(h0,...
'interval',24/sfrq, ...                % hourly data
'start',time(1),...                    % start time is datestr(tuk_time(1))
'latitude',49,...                      % Latitude of obs
'error','cboot',...                    % coloured boostrap CI
'synthesis',1,'output',...
'none','diary','none'); 

Optdata.surgelevels.tidestruc = tidestruc; 
%% Determine delta_w 
% Twn (time window) for averaging, default 1.2-14 days
Twn     = Optdata.surgelevels.Twin; 

% Surge variations level within T-window 
hris  	= (h0-ha);   % risiduals from water level
numl    = ceil((0.5*Twn(1))*sfrq); % sample number, lower 
numu    = ceil((0.5*Twn(2))*sfrq);  % sample number, upper 
hsl     = movmean(hris,[numl  numl],1,'omitnan','Endpoints','fill');
hsu     = movmean(hris,[numu numu],1,'omitnan','Endpoints','fill');
hsm     = hsl-hsu;

%% Check delay with surge level
Sxl    = SALTIDE_quick_godin(Sx,time);
Sxu    = movmean(Sx,[numu numu],1,'omitnan','Endpoints','fill');
Sxm    = Sxl-Sxu;

maxd   = Twn(2)*sfrq;  % max delay equal to upper Twin
numlag = finddelay(Sxm,hsm,maxd);
hsm_lag= NaN(size(hsm));

% shift the array
if numlag == 0
   hsm_lag = hsm;
elseif numlag > 0
   hsm_lag(1+numlag:end) = hsm(1:end-numlag);
elseif numlag < 0
   hsm_lag(1:end+numlag) = hsm(1+abs(numlag):end);    
end

hsm = hsm_lag;
%% Plugh form factor.

nameF          = {'K1','O1','M2','S2'};
nameC           = cellstr(tidestruc.name);
for ff = 1:length(nameF)    
    Fid(ff) = find(strcmp(nameF(ff),nameC));   
end
FormF = (tidestruc.tidecon(Fid(1),1) + tidestruc.tidecon(Fid(2),1))/...
    (tidestruc.tidecon(Fid(3),1)+ tidestruc.tidecon(Fid(4),1));

if FormF  < 0.25
    Optdata.surgelevels.plugh.T     = 1/(tidestruc.freq(Fid(3))*24);
    Optdata.surgelevels.plugh.Type  = 'semidiurnal';
    
elseif FormF > 0.25 &&  FormF < 1.5
    Optdata.surgelevels.plugh.T     = 1/(tidestruc.freq(Fid(3))*24);
    Optdata.surgelevels.plugh.Type  = 'mixed mainly semidiurnal';
elseif FormF > 1.5
    Optdata.surgelevels.plugh.T     = 1/(tidestruc.freq(Fid(1))*24);
    Optdata.surgelevels.plugh.Type  = 'mainly diurnal';
else 
    fprintf('  Something goes wrong %\n',FormF);
end 


end 