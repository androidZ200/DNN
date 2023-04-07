% checking the stability of the solution

nois = 0:0.1:pi/2;
accr = zeros(1,length(nois));
rep = 3;
save=DOES; % we keep the original solution

for iter3=1:length(nois)
    for iter4=1:rep
        % add random noise and check the result
        DOES = exp(1i*(angle(save) + (rand(N,N,size(DOES,3))*2-1)*nois(iter3)));
        check_result;
        accr(iter3) = accr(iter3) + accuracy;
    end
end

accr = accr/rep;
DOES = save;
% plot(nois, accr);

clearvars rep save iter3 iter4;
