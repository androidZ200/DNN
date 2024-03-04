% non-gradient learning method

if exist('P', 'var') ~= 1; P = size(Train,3); end
if exist('epoch', 'var') ~= 1; epoch = 1; end
if exist('batch', 'var') ~= 1; batch = 60; end
if exist('LossFunc', 'var') ~= 1; LossFunc = 'SCE'; end
if exist('cycle', 'var') ~= 1; cycle = 200; end
if exist('sce_factor', 'var') ~= 1; sce_factor = 15; end
if exist('deleted', 'var') ~= 1; deleted = true; end
if exist('DOES_MASK', 'var') ~= 1; DOES_MASK = ones(N,N,length(Propagations), 'single'); end
if exist('DOES', 'var') ~= 1; DOES = DOES_MASK; end
if exist('target_scores', 'var') ~= 1; target_scores = eye(size(MASK,3),ln,'single'); end

max_batch = 500;
batch = min(batch, P);
Accr = 0;
randind = randperm(size(Train,3));
randind = randind(1:P);
accr_graph(1) = nan;

% for Gauss Loss Function
if strcmp(LossFunc, 'Target')
    if exist('Target', 'var') ~= 1
        Target = ((X - permute(coords(:,1), [3 2 1])).^2 + (Y - permute(coords(:,2), [3 2 1])).^2)/(spixel*7)^2;
        Target = normalize_field(exp(-Target)).^2;
    end
    Target = single((permute(Target, [1 2 4 3])));
end

%% training
tic;
for ep=1:epoch
    for iter8=1:batch:P
        min_phase = zeros(N,N,size(DOES,3), 'single');
        for iter7=0:min(batch, max_batch):(batch-1)
            num = TrainLabel(randind(iter8+iter7+(0:min(batch, max_batch)-1)))';
            inum = num+(0:min(batch, max_batch)-1)*size(MASK,3);

            % direct propagation
            W = GetImage(Train(:,:,randind(iter7+(0:batch-1))));
            [me, W, mi] = recognize(W,Propagations,DOES,MASK,is_max);
            I = sum(me);
            Accr = Accr + sum(max(me) == me(num+(0:batch-1)*size(MASK,3)));
            me = me./I;

            % training
            Wend = conj(W(:,:,end,:));
            W(:,:,end,:) = [];
            switch LossFunc
                case 'Target' % the integral Target function
                    F = 4*Wend.*(abs(Wend).^2 - Target(:,:,1,num));
                case 'MSE' % mean squared error
                    p = me;
                    p = p - target_scores(:,num);
                    p = 4*(p-sum(me.*p))./I;
                    F = sum(Wend.*permute(p,[3 4 1 2]).*mi,3);
                case 'SCE' % softmax cross entropy
                    p = exp(sce_factor*me); 
                    p = p./sum(p);
                    alpha = target_scores(:,num);
                    p =  (p - sum(p.*me)).*sum(alpha) + sum(alpha.*me) - alpha;
                    p = p*sce_factor*2./I;
                    F = sum(Wend.*permute(p,[3 4 1 2]).*mi,3);
                otherwise
                    error(['Loss function "' name '" is not exist']);
            end
            % reverse propagation
            F = reverse_propagation(F, Propagations, DOES);
            min_phase = min_phase + sum(W.*F, 4);
        end
        min_phase = pi - angle(min_phase);

        % updating weights
        DOES = exp(1i*min_phase);

        % data output to the console
        if mod(iter8+batch-1 + ep*P, cycle) == 0
            Accr = Accr/max(cycle,batch)*100;
            accr_graph(end+1) = Accr;
            disp(['epoch = ' num2str(ep) '/' num2str(epoch) '; iter = ' num2str(iter8+batch-1) ...
                 '/' num2str(P) '; accr = ' num2str(Accr) '%; time = ' num2str(toc) ';']);
            Accr = 0;
        end
    end
    DOES = DOES_MASK.*exp(1i*angle(DOES));
end

%% clearing unnecessary variables
clearvars num iter7 iter8 ep me mi W Wend F Accr randind min_phase p I max_batch;
if deleted == true
    clearvars epoch P cycle Target batch LossFunc sce_factor;
else
    deleted = true;
    Target = permute(Target, [1 2 4 3]);
end
