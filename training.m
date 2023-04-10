
if exist('iteration', 'var') ~= 1; iteration = 1024; end
if exist('speed', 'var') ~= 1; speed = 1e-1; end
if exist('slowdown', 'var') ~= 1; slowdown = 0.9996; end
if exist('dropout', 'var') ~= 1; dropout = 0; end
if exist('method', 'var') ~= 1; method = 'default'; end
if exist('params', 'var') ~= 1; params = []; end

cycle = 64;
lz = length(doe_plane);
f = [repmat(doe_plane(2:end)-doe_plane(1:end-1), [size(INPUT,3), 1]) (output_plane-doe_plane(end))'];
tmp_data = zeros(N,N,lz);

tic;
for iter7=1:iteration
    gradient = zeros(N,N,lz);
    for iter8=1:size(INPUT,3)
        % direct propagation
        W = recognize(INPUT(:,:,iter8),[doe_plane output_plane(iter8)],DOES,k,U);
        W(:,:,end) = W(:,:,end).*(rand(N) >= dropout);

        % training
        F = conj(W(:,:,end)).*(abs(W(:,:,end)).^2 - OUTPUT(:,:,iter8));
        T = zeros(N,N,lz);
        % reverse propagation
        for iter9=0:lz-1
            F = propagation(F, f(iter8, end-iter9), k, U).*DOES(:,:,end-iter9);
            T(:,:,end-iter9) = -imag(W(:,:,end-iter9-1).*F);
        end
        gradient = gradient + T;
    end
    % updating weights
    norma = max(max(max(abs(gradient))));
    if norma > 0
        gradient = gradient / norma;
    end
    [gradient, tmp_data] = criteria(gradient, tmp_data, method, [params, iter7]);
    DOES = DOES./exp(1i*speed*gradient);
    speed = speed*slowdown;

    % data output to the console
    if mod(iter7, cycle) == 0
        display(['iter = ' num2str(iter7) '/' num2str(iteration) '; time = ' num2str(toc) ';']);
    end
    DOES = exp(1i*angle(DOES));
end

clearvars iter7 iter8 iter9 speed W F T cycle f gradient method params slowdown lz tmp_data norma dropout;
