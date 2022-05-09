function RyA = SALTIDE_RyA(signal,dt,n,Optdata)
%SALTIDE_RyA  Frequency seperation bases on Matte et al. 2013 and 
%             Munk et al.1965 
%
%   This function detrmines the frequency seperation based on the
%   normalized power secturm 
%
%   Syntax:
%   data = SALTIDE_RyA(signal,dt,n)
%
%   Input: 
%   Singal    = timeseries the evaluated singal
%   dt        = time step
%   n         = user-defined criterion ( fraction of its total spectral
%               power)
%   Output:
%   RyA      =  Adjusted Rayleigh criterium (Matte et al. 2013)
%% interpolate linear gaps
id_1   = find(~isnan(signal),1,'first');
id_2   = find(~isnan(signal),1,'last');
signal = fillmissing(signal(id_1:id_2),'linear');

%% define power spectrum
m      = length(signal); %length of signal
signal = signal - nanmean(signal); 

[Pf,w] = pwelch(signal,m); %in units of power per radians per sample
w      = w/2/pi/dt;

%%

%Cumulative integrals
cumP   = cumtrapz(w,Pf);
%Normalizing
cumP   = cumP/cumP(end);

%Frequency corresponding to (1-crit)% of the surface
k = find(cumP>1-n,1,'first');
%plot(cumP)
if ~isempty(k), RyA = w(k-1) + (w(k)-w(k-1))/(cumP(k)-cumP(k-1))*(1-n - cumP(k-1)); end

%% 
Optdata.fmin_ha.Ry.n     = n;
Optdata.fmin_ha.Ry.RyA   = RyA;
end 