function [Optdata] = SALTIDE_Rsqr_list(Optdata) 

coeffcorr = Optdata.pred.stats.coeffcorr; 
namefreq  = Optdata.pred.namefreq;
freqs     = Optdata.pred.freq;
n_freq    = length(freqs); 


if strcmp(Optdata.model,'Q')        
nr_st   = 1 ;
elseif  strcmp(Optdata.model,'QH') 
nr_st = 2;       
elseif  strcmp(Optdata.model,'QHC') 
nr_st = 4; 
end
 %%
count = 1;
for nn = 1:n_freq-1
    for nr = nn+1:n_freq
        id_1 = [nr_st + nn , nr_st  + n_freq +  nn];
        id_2 = [nr_st + nr , nr_st  + n_freq +  nr];

        cc =(coeffcorr(id_1,id_2)); cm = max((cc(:)));
        
        cor_list(count,:) = {namefreq(nn,:), namefreq(nr,:) , cm,  cc(1),  cc(2) ,  cc(3), cc(4)};
        count = count + 1;
    end
end

[~, id ] = sort([cor_list{:,3}],'descend');
cor_list = cor_list(id,:);

Optdata.Rsqr_list = cor_list;
end 