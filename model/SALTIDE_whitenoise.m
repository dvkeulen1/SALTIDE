% from NS tide! 

function [Cfsr] = SALTIDE_whitenoise(cfs,sigma,cases) 
MU   = cfs';
Cfsr = mvnrnd(MU,sigma,cases-1);
end 