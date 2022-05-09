function [Optdata] = SALTIDE_sig_consit(cfs_dis,Optdata) % check 


%% 
gp    = Optdata.prop.gp;                     
nr_fr = length(Optdata.fmin_ha.Pars.freq);    % number of used frequencies

if strcmp(Optdata.model,'Q') % Discharge model   
    nr_st = 1;
elseif  strcmp(Optdata.model,'QH') % Stage model
    nr_st = 2;
elseif  strcmp(Optdata.model,'QHC') % Stage model
    nr_st = 4;
end


%%  get cosine and sine parts
if strcmp(Optdata.model,'Q') % Discharge model   
        dc2  =  cfs_dis(:,nr_st+1:nr_st+nr_fr);             % cosine parts
        ds2  =  cfs_dis(:,nr_st+nr_fr+1:nr_st+nr_fr*2);     % sine parts
            
elseif  strcmp(Optdata.model,'QH') % Stage model
        dc2  =  cfs_dis(:,nr_st+1:nr_st+nr_fr);             % cosine parts
        ds2  =  cfs_dis(:,nr_st+nr_fr+1:nr_st+nr_fr*2);     % sine parts
        dc3  =  cfs_dis(:,nr_st+nr_fr*2+1:nr_st+nr_fr*3);   % cosine parts
        ds3  =  cfs_dis(:,nr_st+nr_fr*3+1:nr_st+nr_fr*4);   % sine parts

elseif  strcmp(Optdata.model,'QHC') % Stage model
        dc1  =  cfs_dis(:,nr_st+1:nr_st+nr_fr);             % cosine parts
        dc2  =  cfs_dis(:,nr_st+nr_fr*2+1:nr_st+nr_fr*3);             % cosine parts
        dc3  =  cfs_dis(:,nr_st+nr_fr*4+1:nr_st+nr_fr*5);   % cosine parts
        ds1  =  cfs_dis(:,nr_st+nr_fr+1:nr_st+nr_fr*2);     % sine parts           
        ds2  =  cfs_dis(:,nr_st+nr_fr*3+1:nr_st+nr_fr*4);     % sine parts
        ds3  =  cfs_dis(:,nr_st+nr_fr*5+1:nr_st+nr_fr*6);   % sine parts
end


% Check wat NS-Cluster does..  (Probebly clusters the input around one value, to overcome wrapping!)
fmajTS = [];  phaTS = []; emaj = [];  epha = []; srn = []; srn_mean = []; sigcon = [];

for ii = 1:nr_fr
    
    if strcmp(Optdata.model,'Q') % Discharge model  
        % AK shoudl be matrix with variation x time variation
        Ak   =  sqrt(dc2(:,ii).^2 + ds2(:,ii).^2)' .*Optdata.fmin_ha.Out.QrD0;   % nubo x cases
        ak   = (atan2(ds2(:,ii),dc2(:,ii)))';                                   % 1 x cases
      
        %- z_k or z_k (Eq A15) 
        aplus   = ((Ak.*cos(ak)) - 1i*((Ak.*sin(ak))))/2;            % plus     (dc - 1i ds)
        amin    = ((Ak.*cos(ak)) + 1i*((Ak.*sin(ak))))/2;            % amp min  (dc - 1i ds)
    elseif strcmp(Optdata.model,'QH')
        Ak   =  sqrt(dc2(:,ii).^2 + ds2(:,ii).^2)' .*Optdata.fmin_ha.Out.QrD0;   % nubo x cases
        Bk   =  sqrt(dc3(:,ii).^2 + ds3(:,ii).^2)' .*Optdata.fmin_ha.Out.QrD0hs; % nubo x cases
        ak   =  (atan2(ds2(:,ii),dc2(:,ii)))';                                   % 1 x cases
        bk   =  (atan2(ds3(:,ii),dc3(:,ii)))';                                   % 1 x cases

        % z_k or z_k (Eq A15) 
        % nubo x cases 
        aplus   = ((Ak.*cos(ak)+Bk.*cos(bk)) - 1i*((Ak.*sin(ak)+Bk.*sin(bk))))/2;            % plus     (dc - 1i ds)
        amin    = ((Ak.*cos(ak)+Bk.*cos(bk)) + 1i*((Ak.*sin(ak)+Bk.*sin(bk))))/2;            % amp min  (dc - 1i ds)        

     elseif strcmp(Optdata.model,'QHC')
        Ak   =  sqrt(dc1(:,ii).^2 + ds1(:,ii).^2)' .*Optdata.fmin_ha.Out.D0;
        Bk   =  sqrt(dc2(:,ii).^2 + ds2(:,ii).^2)' .*Optdata.fmin_ha.Out.QrD0;   % nubo x cases
        Ck   =  sqrt(dc3(:,ii).^2 + ds3(:,ii).^2)' .*Optdata.fmin_ha.Out.QrD0hs; % nubo x cases
        ak   =  (atan2(ds1(:,ii),dc1(:,ii)))';                                   % 1 x cases
        bk   =  (atan2(ds2(:,ii),dc2(:,ii)))';                                   % 1 x cases
        ck   =  (atan2(ds3(:,ii),dc3(:,ii)))';                                   % 1 x cases

        % z_k or z_k (Eq A15) 
        % nubo x cases 
        aplus   = ((Ak.*cos(ak)+Bk.*cos(bk)+Ck.*cos(ck)) - 1i*((Ak.*sin(ak)+Bk.*sin(bk)+Ck.*sin(ck))))/2;            % plus     (dc - 1i ds)
        amin    = ((Ak.*cos(ak)+Bk.*cos(bk)+Ck.*cos(ck)) + 1i*((Ak.*sin(ak)+Bk.*sin(bk)+Ck.*sin(ck))))/2;            % amp min  (dc - 1i ds)        

    end
    
    %% Time dependent phase and amplitude
    amp       = abs(aplus)+abs(amin);       % A13...
    phase     = angle(amin).*(180/pi);      % A14... % conversion from rad to deg (180/pi) 
    phase     = SALTIDE_cluster(phase, 360); 
    
    fmajTS(ii,:) = amp(:,1); 
    phaTS(ii,:)  = phase(:,1); 
    
    emaj(ii,:)   = median(abs(amp-median(amp,2)),2)/.6745*1.96;
    epha(ii,:)   = median(abs(phase-median(phase,2)),2)/.6745*1.96;
 
    srn(ii,:)    = (fmajTS(ii,:) ./emaj(ii,:)).^2; 
    srn_mean(ii) =  nanmean(srn(ii,:)); 
    sigcon(ii)   =  srn_mean(ii)>4; 
    
    freqsSig     = Optdata.fmin_ha.Pars.freq(logical(sigcon)); 
    nameSig      = Optdata.fmin_ha.Pars.name(logical(sigcon),:)';

end 

% save data to output 
Optdata.sigcon.sigcon       = sigcon;   %significance
Optdata.sigcon.freqs_sig    = freqsSig; 
Optdata.sigcon.nameSig      = nameSig;

Optdata.sigcon.fmajTS       = fmajTS'; %amplitudes 
Optdata.sigcon.phaTS        = phaTS';  %resulting phase
Optdata.sigcon.emaj         = emaj';   %error amplitude
Optdata.sigcon.epha         = epha';   %error phase
Optdata.sigcon.srn          = srn';    %SNR 
Optdata.sigcon.srn_mean     = srn_mean; %mean SNR 
end 