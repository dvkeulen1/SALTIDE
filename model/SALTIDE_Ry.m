function  [Ry Optdata] = SALTIDE_Ry(x,Optdata)
%SALTIDE_RyA  Returns de traditional or adjusted rayleigh criterium
%% Unpack input
nubo   = Optdata.prop.nubo;
dt     = Optdata.prop.dt;
n      = Optdata.prop.n; 
Qr     = Optdata.invars.Qr;

%%Rayleigh criterium
RyC       = 1/(nubo*dt);  % 1/(m*dt) [1/d] Traditional 

if  strcmp(Optdata.power,'PC')  
    QD0       = Qr.^(1-x(2));  % Q / Q^x(2), this is when powers are coupled.
else
    QD0       = Qr.^(1-x(1));  % Q / Q^x(1), normal     
end 
RyA       = SALTIDE_RyA(QD0,dt,n,Optdata);
Ry        = max([RyC  RyA]);

%%
Optdata.fmin_ha.Ry.n    = n;
Optdata.fmin_ha.Ry.RyC  = RyC;
Optdata.fmin_ha.Ry.RyA  = RyA;
Optdata.fmin_ha.Ry.Ry   = Ry;
end 