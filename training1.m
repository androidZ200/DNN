% gradient learning method

if exist('P', 'var') ~= 1; P = size(Train,3); end
if exist('epoch', 'var') ~= 1; epoch = 1; end
if exist('speed', 'var') ~= 1; speed = 1e-1; end
if exist('slowdown', 'var') ~= 1; slowdown = 0.999; end
if exist('batch', 'var') ~= 1; batch = 30; end
if exist('LossFunc', 'var') ~= 1; LossFunc = 'SCE'; end
if exist('method', 'var') ~= 1; method = 'SGD'; end
if exist('params', 'var') ~= 1; params = []; end
if exist('cycle', 'var') ~= 1; cycle = 200; end
if exist('deleted', 'var') ~= 1; deleted = true; end
if exist('DOES_MASK', 'var') ~= 1; DOES_MASK = ones(N,N,length(Propagations)); end
if exist('DOES', 'var') ~= 1; DOES = DOES_MASK; end
if exist('sce_factor', 'var') ~= 1; sce_factor = 15; end
if exist('target_scores', 'var') ~= 1; target_scores = eye(size(MASK,3),ln); end
if exist('iter_gradient', 'var') ~= 1; iter_gradient = 0; end

batch = min(batch, P);
Accr = 0;
accr_graph(1) = nan;
if exist('tmp_data', 'var') ~= 1;
    tmp_data = zeros(N,N,size(DOES,3));
end

% for Gauss Loss Function
if strcmp(LossFunc, 'Target')
    if exist('Target', 'var') ~= 1
        Target = (bsxfun(@minus,X,permute(coords(:,1), [3 2 1])).^2 + ...
                  bsxfun(@minus,Y,permute(coords(:,2), [3 2 1])).^2) ...
                  /(spixel*7)^2;
        Target = normalize_field(exp(-Target)).^2;
    end
    Target = permute(Target, [1 2 4 3]);
end

tic;
for ep=1:epoch
    randind = randperm(size(Train,3));
    randind = randind(1:P);
    for iter7=1:batch:P
        num = TrainLabel(randind(iter7+(0:batch-1)))';

        % direct propagation
        W = GetImage(Train(:,:,randind(iter7+(0:batch-1))));
        [me, W, mi] = recognize(W,Propagations,DOES,MASK,is_max);
        I = sum(me);
        me = bsxfun(@rdivide,me,I);
        Accr = Accr + sum(max(me) == me(num+(0:batch-1)*size(MASK,3)));
        
        % training
        Wend = conj(W(:,:,end,:));
        W(:,:,end,:) = [];
        switch LossFunc
            case 'Target' % the integral Target function
                F = 4*Wend.*(abs(Wend).^2 - Target(:,:,1,num));
            case 'MSE' % mean squared error
                p = me;
                p = p - target_scores(:,num);
                p = 4*bsxfun(@rdivide,(bsxfun(@minus,p,sum(me.*p))),I);
                F = sum(bsxfun(@times,bsxfun(@times,Wend,permute(p,[3 4 1 2])),mi),3);
            case 'SCE' % softmax cross entropy
                p = exp(sce_factor*me); 
                p = bsxfun(@rdivide,p,sum(p));
                alpha = target_scores(:,num);
                p =  bsxfun(@plus,bsxfun(@times,bsxfun(@minus,p,sum(p.*me)),sum(alpha)),sum(alpha.*me)) - alpha;
                p = bsxfun(@rdivide,p*sce_factor*2,I);
                F = sum(bsxfun(@times,bsxfun(@times,Wend,permute(p,[3 4 1 2])),mi),3);
            otherwise
                error(['Loss function "' name '" is not exist']);
        end
        % reverse propagation
        F = reverse_propagation(F, Propagations, DOES);
        gradient = -imag(sum(W.*F, 4).*DOES);
    
        % updating weights
        iter_gradient = iter_gradient + 1;
        [gradient, tmp_data] = criteria(gradient, tmp_data, method, [params, iter_gradient]);
        DOES = DOES.*exp(-1i*speed*gradient);
        speed = speed*slowdown;

        % data output to the console
        if mod(iter7+batch-1 + ep*P, cycle) == 0
            Accr = Accr/max(cycle,batch)*100;
            accr_graph(end+1) = Accr;
            display(['iter = ' num2str(iter7+batch-1 + (ep-1)*P) '/' num2str(P*epoch) ...
                '; accr = ' num2str(Accr) '%; time = ' num2str(toc) ';']);
            Accr = 0;
        end
    end
    DOES = DOES_MASK.*exp(1i*angle(DOES));
end

% clearing unnecessary variables
clearvars num iter7 ep me mi W Wend F Accr randind gradient p I alpha;
if deleted == true
    clearvars P epoch speed slowdown batch LossFunc method params cycle ...
        deleted Target tmp_data sce_factor target_scores iter_gradient;
else
    deleted = true;
    if strcmp(LossFunc, 'Target')
        Target = permute(Target, [1 2 4 3]);
    end
end
