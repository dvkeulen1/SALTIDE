
function [nr0,n0] = SALTIDE_AmpAndRange(h0,sfrq)
%SALTIDE_surgelevel makes an estimates of tidal amplitude and range
%                   
%   This function etimates tidal amplitude trough determining the max and 
%   minimun water level from 3 time windows (24, 24, 25 hours). The end 
%   product is averaged to obtain a smooth timeseries 
%
%   Syntax:
%   hs,ha,tidestruc] = SALTIDE_surgelevel(h0,Sx,time,sfrq)
%
%   Input: 
%   h0        = timeseries of the water level elevations at the mouth
%   sfrq      = sample frequency 
%
%   Output:
%   nr0       =  estimate tidal range
%   nr        =  estimate of tidal amplitude
%% Determine averaging samples 
Twindows        = [24 24 25]./24; 
Nsamples        = ceil(Twindows*sfrq/2); 

%% Range and amplitude
c               = 0;  
series_max      = h0;
series_min      = h0;

while c < length(Twindows)
c = c+1;
series_max      = movmax(series_max ,[Nsamples(c) Nsamples(c)],'Endpoints','fill');
series_min      = movmin(series_min,[Nsamples(c) Nsamples(c)],'Endpoints','fill');
end 

nr0             = series_max-series_min; % smooth output
nr0             = movmean(nr0 ,[Nsamples(end) Nsamples(end)],'Endpoints','fill');
n0              = nr0./2; 
nr0(nr0 == 0)   = NaN; 
n0(n0 == 0)     = NaN; 
end 