function [lsq] = SALTIDE_SSE(var1,var2)
gp = ~isnan(var1) & ~isnan(var2); 

sse = sqrt(sum((var1(gp) - var2(gp)).^2)./(length(var1(gp))-1));
lsq = sum((var1(gp) - var2(gp)).^2);
end
