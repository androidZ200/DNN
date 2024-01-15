% checking the stability of the solution

nois = 0:0.1:pi/2;
accr = zeros(rep,length(nois));
rep = 3;
save=DOES; % we keep the original solution

for iter4=1:rep
    for iter3=length(nois):-1:2
        % add random noise and check the result
        DOES = exp(1i*(angle(save) + gpuArray((rand(N,N,size(DOES,3))*2-1)*nois(iter3))));
        check_result;
        accr(iter4,iter3) = accuracy;
    end
end

DOES = save;
check_result;
accr(:,1) = accuracy;

plot(nois, mean(accr));

clearvars rep save iter3 iter4;
