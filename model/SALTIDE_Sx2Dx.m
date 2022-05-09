function DxD0     = SALTIDE_Sx2Dx(Sx,Sr,S0,gp,K)
DxD0              = NaN(size(Sx)); 
SxS0              = ((Sx-Sr)./(S0-Sr)); 
SxS0(SxS0<0)      = 0; 
DxD0(gp)          = (((SxS0(gp)).^K)-1); % 
end 

  