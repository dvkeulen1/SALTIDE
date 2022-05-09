function [Sxc,Sprd,pp,Optdata] = SALTIDE_SxSr_clip(Sx,Sr,Qr,time,Offset,Optdata)
%SALTIDE_SxSr_clip  estimates if observation statistically exceeds the
%                   river salinity 
%
%   This function first find the non-simultaneous observation bounds and used
%   these to evaluate of the salinity from a upstream points exceed the
%   confidence bounds. 
%
%   Syntax:
%   data = godin_filter(data,varargin)
%
%   Input: 
%   Sx        = timeseries of salinity measured in a estuary
%   Sr        = timeseries of river salinity
%   Qr        = timeseries of river discharge
%   sfrq      = sample frequency 
%   Offset    = Offset to apply an correcton on Sx
%
%   Output:
%   Sxc      =  Clipped signal of Sx where all value that not statistically 
%               exceed Sr are are replaced by NaNs.              
%   Sprd     =  predicted Sr signal
%   pp       =  points that are not statistically different from Sr
%   sfit     =  function for Sr
%% moving mean to eliminate any tidal variations
Sx  = Sx + Offset; 
gp  = ~isnan(Qr) & ~isnan(Sr); 
Sr  = SALTIDE_quick_godin(Sr,time);

% Regression model PSU = Backroundload/discharge + concentration discharge
% f(x) = p1* (1/Qr) + p2
conf    = 0.95; % 95 % confidence interval
sfit    = fit(1./Qr(gp),Sr(gp),'poly1');
Sprd    = NaN(size(Sx)); 
Sprd(gp)= feval(sfit,1./Qr(gp)); 
Sbnd    = predint(sfit,1./Qr,0.95,'observation','off'); % get nonsimultaneous observation bounds

% Set all values that exceed 95 bound to NaN
pp       =  (Sx - (Sbnd(:,2))) >  0;
Sxc      =  Sx;
Sxc(~pp) =  NaN; 

%% set info 
Optdata.SxSr_clip.sfit = sfit; 
Optdata.SxSr_clip.sfit = Sr; 
end