function Optdata = SALTIDE_ini_ha(Optdata);

signal = Optdata.invars.Sx;
time   = Optdata.invars.time;  
dt     = Optdata.prop.dt; 
%%
% select consituents within time window (twin)
% all freq higher then MF (seasonal);
% all freq low than MNO5 
twin = [0.74 5.7578]; %[MF MNO5] 

% HA for h0 (water levels at the mouth)  
signal          = signal-nanmean(signal); 
nobsu           = length(signal); 
gp              = ~isnan(signal); 
centraltime     = time(1)+floor(nobsu/2)*dt;
consts          = t_getconsts(centraltime);
freqs           = consts.freq'*24; % from cph to cpd

% Eliminate all frequencies above 2 cpd
inc_freqs       = freqs > twin(1) & freqs < twin(2);
freqs_name      = consts.name(inc_freqs,:); % alles groter dan 2 cpd 
freqs           = freqs (inc_freqs);
freqs_nr        = length(freqs);                                % number of freqs.
freqs_ang       = freqs.*2*pi;                                  % angular freqs.      

% Calculate signal, amplitudes and phase of consituants
tc              = [cos(freqs_ang.*time(gp))  sin(freqs_ang.*time(gp))];
coefs           = tc\signal(gp);
amp             = sqrt(coefs(1:freqs_nr).^2 + coefs(1+freqs_nr:end).^2);
phs             = atan(-coefs(1+freqs_nr:end)./coefs(1:freqs_nr));
singal_pred     = tc*coefs;  
resout          = singal_pred - signal(gp); 
varx            = cov(singal_pred);   
varxr           = cov(resout(~isnan(resout)));

%% Real input of explained variance 
Optdata.ini_ha.freq   = freqs(:);
Optdata.ini_ha.name           = freqs_name;
Optdata.ini_ha.amps           = amp(:);
Optdata.ini_ha.phs            = phs(:); 
Optdata.ini_ha.resout         = resout;
Optdata.ini_ha.singal_out     = singal_pred;
Optdata.ini_ha.lsqfit         = 100*(varxr/varx);
end 