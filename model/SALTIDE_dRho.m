function Rho = SALTIDE_dRho(S0,Sr,Tc) 
%SALTIDE_SxSr_clip  Converts salinity to a density UNESCO 1981 formulation
%                   or through saline expensivity
%
%   This function converst the salinity to a density, using NESCO 1981 formulation
%
%   Syntax:
%   data = godin_filter(data,varargin)
%
%   Input: 
%   Sx        = timeseries of salinity measured in a estuary
%   Sr        = timeseries of river salinity
%   Tc        = timeseries of temperature
%
%   Output:
%   Rho       = density obtained from Sx 
%% Variables
S0 = S0(:); % Salinity at the mouth
Sr = Sr(:); % Salinity at riverboundary
Tc = Tc(:);  % Temperature
%% UNESCO 1981 formulation (checked using table page 19)
%  Function is applible for gauge measured salinity (assuming P = 0). 
bx = [8.224493*(10^-1)  ; -4.0899*(10^-3) ; 7.6438*(10^-5) ; -8.2467*(10^-7); 5.3875*(10^-9)];  
cx = [-5.72466*(10^-3)  ; 1.0227 *(10^-4) ; -1.6546* (10^-6) ];
d0 = [4.8314*10^-4];  
ax = [999.842; 6.793*10^-2; -9.095*10^-3; 1.001 *10^-4; -1.120*10^-6; 6.536 *10^-9];
%%
pw_trm1 = @(Tc)   (ax(1) + ax(2).*Tc + ax(3).*Tc.^2 + ax(4).*Tc.^3 + ax(5).*Tc.^4 + ax(6).*Tc.^5) ;
ps_trm2 = @(Tc,S) (bx(1) + bx(2).*Tc + bx(3).*Tc.^2 + bx(4).*Tc.^3 + bx(5).*Tc.^4).*S; 
ps_trm3 = @(Tc,S) (cx(1) + cx(2).*Tc + cx(3).*Tc.^2 ).*S.^(3/2);
ps_trm4 = @(S) (d0.*S.^2);
ps      = @(Tc,S) pw_trm1(Tc) + ps_trm2(Tc,S) + ps_trm3(Tc,S) + ps_trm4(S); 

%% Calculate relative density difference 
Rho  =  (ps(Tc,S0)-ps(Tc,Sr))./ps(Tc,Sr);
end 