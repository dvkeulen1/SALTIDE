function dataf = SALTIDE_quick_godin(data,time)

% data is series
% is d3d time series (matlabdatenume)
% Settings per filter window

dataf = data; 
Twin  = [24,24,25];
dt    = diff(time,1); dt = dt(1) .*24;
Nwin  = ceil(Twin./dt);

for ii = 1:length(Twin)
    if ~mod(Nwin(ii),2)
        nb =floor((Nwin(ii)-1)/2); nf = nb;
    else
        nb =floor((Nwin(ii)-1)/2); nf = nb-1;
    end 
    dataf = movmean(dataf,[nb nf],'omitnan','Endpoints','fill');
end 
end 


