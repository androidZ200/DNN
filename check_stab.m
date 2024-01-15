% checking the stability of the solution

nois = linspace(0, pi/2, 8);
rep = 4;

accr = zeros(rep,length(nois));
save=DOES; % we keep the original solution

for iter4=1:rep
    for iter3=length(nois):-1:2
        % add random noise and check the result
        display(['noise = ' num2str(nois(iter3)) '(' num2str(iter4) ')']);
        DOES = exp(1i*(angle(save) + (rand(N,N,size(DOES,3))*2-1)*nois(iter3)));
        check_result;
        accr(iter4,iter3) = accuracy;
    end
end

DOES = save;
check_result;
accr(:,1) = accuracy;

figure; hold on; grid on;
for iter4 = 1:rep
    plot(nois, accr(iter4,:), '-r');
end
plot(nois, mean(accr), '-k', 'LineWidth', 3);

clearvars rep save iter3 iter4;
