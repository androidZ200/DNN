
% checking the stability of the solution

nois = linspace(0, pi/4, 5);
rep = 3;

accr = zeros(rep,length(nois));
minc = zeros(rep,length(nois));
save=DOES; % we keep the original solution

for iter4=1:rep
    for iter3=length(nois):-1:2
        % add random noise and check the result
        display(['noise = ' num2str(nois(iter3)) '(' num2str(iter4) ')']);
        DOES = exp(1i*(angle(save) + (rand(N,N,size(DOES,3))*2-1)*nois(iter3)));
        check_result;
        accr(iter4,iter3) = accuracy;
        minc(iter4,iter3) = min_contrast;
    end
end

DOES = save;
check_result;
accr(:,1) = accuracy;
minc(:,1) = min_contrast;

clearvars rep save iter3 iter4;
return;

%% accuracy graph

figure; hold on; grid on;
title('accuracy');
for iter4 = 1:size(accr,1)
    plot(nois, accr(iter4,:), 'xk');
end
plot(nois, mean(accr), 'LineWidth', 2, 'color', [32 145 201]/255);
xlabel('nois');
ylabel('accuracy, %');

clearvars iter4;


%% min_contrast graph

figure; hold on; grid on;
title('min contrast');
for iter4 = 1:size(minc,1)
    plot(nois, minc(iter4,:), 'xk');
end
plot(nois, mean(minc), 'LineWidth', 2, 'color', [201 88 32]/255);
xlabel('nois');
ylabel('min contrast, %');

clearvars iter4;
