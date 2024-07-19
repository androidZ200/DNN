% analytical method for calculating DOE
P = size(Train,3);
Weights = ones(ln, 1);

vv = single((-1).^(1:N));
vv = vv'*vv;

% beta - target phase function
% beta = -k*sqrt((X - coords(num, 1)).^2 + (Y - coords(num, 2)).^2 + (z(end) - z(num_doe))^2);
beta = zeros(N,N,ln,'single');
for num = 1:ln
    beta(:,:,num) = (X - coords(num, 1)).^2 + (Y - coords(num, 2)).^2 < pixel^2;
    beta(:,:,num) = normalize_field(beta(:,:,num));
    beta(:,:,num) = angle(ifft2(beta(:,:,num).*vv).*vv);
end

tic;
for num_doe = 1:length(Propagations) % we teach DOE in turn starting from 1
    AA = zeros(N, N, ln,'single'); % array for accumulating digits

    parfor iter = 1:P
        num = TrainLabel(iter);
        CURR = GetImage(Train(:,:,iter));
        CURR = direct_propagation(CURR, Propagations(1:num_doe),DOES);
        CURR = CURR(:,:,end);
        tmpAA = zeros(N,N,ln,'single');
        tmpAA(:,:,num) = (abs(CURR).^2).*exp(1i*(angle(CURR) - beta(:,:,num)));
        AA = AA + tmpAA;
    end
    
    % we select weighting factors to reduce the error
    for iter4=1:16
        AAA = zeros(N,'single');
        for num = 1:ln
            AAA = AAA + Weights(num)*AA(:,:,num);
        end
        DOES(:,:,num_doe) = exp(-1i.*angle(AAA));
        
        check_result;
        Weights = Weights - 0.001*(diag(err_tabl) - accuracy);
    end
    
    ndisp(['DOE ' num2str(num_doe) ' from ' num2str(length(z)-1) ' is done; time = ' num2str(toc) ' s']);
end

clearvars alpha beta num_doe AAA AA num CURR P iter begin dd iter4 vv;
