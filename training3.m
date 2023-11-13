% the Gershberg-Saxton algorithm

if exist('P', 'var') ~= 1; P = size(Train,3); end
if exist('epoch', 'var') ~= 1; epoch = 1; end;
if exist('Iteration', 'var') ~= 1; Iteration = 1; end;
if exist('batch', 'var') ~= 1; batch = min(10, P); end;
if exist('alghoritm', 'var') ~= 1; alghoritm = 1; end;
if exist('cycle', 'var') ~= 1; cycle = 200; end
if exist('deleted', 'var') ~= 1; deleted = true; end

% for Gauss Loss Function
if exist('Target', 'var') ~= 1
    Target = zeros(N,N,ln);
    for num=1:ln
        Target(:,:,num) = exp(-((X - coords(num,1)).^2 + (Y - coords(num,2)).^2)/2/(0.0198)^2);
        Target(:,:,num) = normalize_field(Target(:,:,num));
    end
end

batch = min(batch, P);
cycle = min(cycle, P);
H = zeros(N,N,ln);

tic;
for ep=1:epoch
    randind = randperm(size(Train,3));
    randind = randind(1:P);
    for iter7=1:batch:P
        for iter8=1:Iteration
            Tmp = zeros(N);
            
            if alghoritm == 1 % Alghoritm GS part 1
                % Forward propagation
                for iter9=0:batch-1
                    W = GetImage(Train(:,:,randind(iter7+iter9)));
                    W = Propagations{1}(W.*DOES);
                    Tmp = Tmp + W.*Target(:,:,TrainLabel(randind(iter7+iter9)));
                end
                psi = exp(1i*angle(Tmp));
                Tmp = zeros(N);

                % Backward propagation
                for num=1:size(Target,3)
                    H(:,:,num) = conj(Propagations{1}(conj(Target(:,:,num).*psi)));
                end
                 for iter9=0:batch-1
                    W = GetImage(Train(:,:,randind(iter7+iter9)));
                    Tmp = Tmp + H(:,:,TrainLabel(randind(iter7+iter9))).*conj(W);
                 end
                DOES = exp(1i*angle(Tmp));
                
            elseif alghoritm == 2  % Alghoritm GS part 2
                for iter9=0:batch-1
                    % Forward propagation
                    W = GetImage(Train(:,:,randind(iter7+iter9)));
                    F = Propagations{1}(W.*DOES);

                    % Backward propagation
                    F = Target(:,:,TrainLabel(randind(iter7+iter9))).*exp(1i*angle(F));
                    F = conj(Propagations{1}(conj(F)));
                    Tmp = Tmp + F.*conj(W);
                end
                DOES = exp(1i*angle(Tmp));
                
            else
                error(['Alghoritm "' num2str(alghoritm) '" is not exist']);
            end
            
        end
        
        % data output to the console
        if mod(iter7+batch-1, cycle) == 0
            display(['epoch = ' num2str(ep) '/' num2str(epoch) '; iter = ' num2str(iter7+batch-1) ...
                 '/' num2str(P) '; time = ' num2str(toc) ';']);
        end
    end
end


% clearing unnecessary variables
clearvars iter7 iter8 iter9 num H W F Tmp psi randind ep;
if deleted == true
    clearvars Targeta P Iteration batch cycle epoch;
else
    deleted = true;
end