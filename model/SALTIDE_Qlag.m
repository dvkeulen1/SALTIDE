function [Qr_lag,Optdata] = SALTIDE_Qlag (Qr,hx,sfrq,Optdata)
warning('off','all')
%% Check the input for nan values
maxlag          = ceil(14*sfrq);              % maximun number of samples, hard coded at 14 days 
Qr_gp           = Qr(~isnan(Qr)&~isnan(hx));  % remove non-nan data
hx_gp           = hx(~isnan(Qr)&~isnan(hx));

%% Find the lag time 
numlag  = finddelay(hx,Qr,maxlag); % number of lags
timelag = numlag/sfrq;             % lag time 

numlag  = 86

%% Shift the time series
Qr_lag  = NaN(size(Qr));

if numlag == 0
    Qr_lag = Qr;
elseif numlag > 0
    Qr_lag(1+numlag:end) = Qr(1:end-numlag);
elseif numlag < 0
    Qr_lag(1:end+numlag) = Qr(1+abs(numlag):end);    
end 

%%  Set info and print to cmd. 
Optdata.Qlag.numblag = numlag;
Optdata.Qlag.timelag = timelag;

fprintf('Max correl between Qr and h0 at %d samples, time lag: %5.2f [d] %\n',[numlag timelag]);
end 