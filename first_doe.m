% analytical method for calculating DOE
P = 2^9;
Weights = ones(length(nums), 1);

tic;
for num_doe = 1:(length(z)-1) % we teach DOE in turn starting from 1
    AA = zeros(N, N, length(nums)); % array for accumulating digits
    for num = 1:length(nums)
        % beta - target phase function
        beta = -k*sqrt((X - coords(num, 1)).^2 + (Y - coords(num, 2)).^2 + (z(end) - z(num_doe))^2);
        for iter = 1:P
            CURR = readimage([path, 'train/', num2str(nums(num)), '/', num2str(iter), '.bmp'], N, (N-AN)/2);
            CURR = propagation(CURR, z(1));
            for dd = 1:num_doe-1
                CURR = propagation(B, CURR.*DOES(:,:,dd), k, z(dd+1) - z(dd));
            end
            AA(:,:,num) = AA(:,:,num) + (abs(CURR).^2).*exp(1i*(angle(CURR) - beta));
        end
        display(['num ' num2str(nums(num)) ' is done; time = ' num2str(toc) ' s']);
    end
    
    % we select weighting factors to reduce the error
    for iter4=1:16
        AAA = zeros(N);
        for num = 1:length(nums)
            AAA = AAA + Weights(num)*AA(:,:,num);
        end
        DOES(:, :, num_doe) = exp(-1i.*angle(AAA));
        
        check_result;
        Weights = Weights - 0.001*(diag(tabl2) - accuracy);
    end
    
    display(['DOE ' num2str(num_doe) ' from ' num2str(length(z)-1) ' is done; time = ' num2str(toc) ' s']);
end

clearvars alpha beta num_doe AAA AA num CURR P iter begin dd iter4;
