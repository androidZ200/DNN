
% checking the stability of the solution

nois = linspace(0, pi/4, 5);
rep = 3;

accr = zeros(rep,length(nois), 'single');
minc = zeros(rep,length(nois), 'single');
save=DOES; % we keep the original solution

for iter4=1:rep
    for iter5=length(nois):-1:2
        % add random noise and check the result
        ndisp(['noise = ' num2str(nois(iter5)) '(' num2str(iter4) ')']);
        DOES = exp(1i*(angle(save) + (rand(N,N,size(DOES,3))*2-1)*nois(iter5)));
        check_result;
        accr(iter4,iter5) = accuracy;
        minc(iter4,iter5) = min_contrast;
    end
end

DOES = save;
check_result;
accr(:,1) = accuracy;
minc(:,1) = min_contrast;

figure; hold on; grid on;
for iter4 = 1:rep
    plot(nois, accr(iter4,:), '-r');
end
plot(nois, mean(accr), '-k', 'LineWidth', 3);


clearvars rep save iter4 iter5;
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
