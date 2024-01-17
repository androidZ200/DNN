% non-gradient learning method

if exist('P', 'var') ~= 1; P = size(Train,3); end
if exist('epoch', 'var') ~= 1; epoch = 1; end
if exist('batch', 'var') ~= 1; batch = 60; end
if exist('LossFunc', 'var') ~= 1; LossFunc = 'SCE'; end
if exist('IntensityFactor', 'var') ~= 1; IntensityFactor = 2; end
if exist('cycle', 'var') ~= 1; cycle = 200; end
if exist('sce_factor', 'var') ~= 1; sce_factor = 15; end
if exist('deleted', 'var') ~= 1; deleted = true; end

batch = min(batch, P);
cycle = min(cycle, P);
Accr = 0;
randind = randperm(size(Train,3));
randind = randind(1:P);
accr_graph(1) = nan;

% for Gauss Loss Function
if exist('Target', 'var') ~= 1
    Target = (bsxfun(@minus,X,permute(coords(:,1), [3 2 1])).^2 + ...
              bsxfun(@minus,Y,permute(coords(:,2), [3 2 1])).^2) ...
              /(spixel*7)^2;
    Target = normalize_field(exp(-Target));
end
Target = permute(Target, [1 2 4 3]);

tic;
for ep=1:epoch
    for iter7=1:batch:P      
        num = TrainLabel(randind(iter7+(0:batch-1)))';

        % direct propagation
        W = GetImage(Train(:,:,randind(iter7+(0:batch-1))));
        [me, W, mi] = recognize(W,Propagations,DOES,MASK,is_max);
        I = sum(me);
        me = bsxfun(@rdivide,me,I);
        Accr = Accr + sum(max(me) == me(num+(0:batch-1)*size(MASK,3)));

        % training
        We = conj(W(:,:,end,:));
        W(:,:,end,:) = [];
        switch LossFunc
            case 'Target' % the integral Gaussian function
                F = 4*We.*(abs(We).^2 - Target(:,:,1,num));
            case 'MSE' % standard deviation
                S = me;
                me(num+(0:batch-1)*size(MASK,3)) = me(num+(0:batch-1)*size(MASK,3)) - 1;
                me = bsxfun(@rdivide,(bsxfun(@minus,me,sum(me.*S))),4*I);
                F = sum(bsxfun(@times,bsxfun(@times,We,permute(me,[3 4 1 2])),mi),3);
            case 'SCE' % softmax cross entropy
                p = exp(sce_factor*me); 
                p = bsxfun(@rdivide,p,sum(p));
                p = bsxfun(@minus,p,bsxfun(@minus,sum(p.*me),me(num+(0:batch-1)*size(MASK,3))));
                p(num+(0:batch-1)*size(MASK,3)) = p(num+(0:batch-1)*size(MASK,3))-1;
                p = bsxfun(@rdivide,p*sce_factor*2,I);
                F = sum(bsxfun(@times,bsxfun(@times,We,permute(p,[3 4 1 2])),mi),3);
            otherwise
                error(['Loss function "' name '" is not exist']);
        end
        % find global minimum of loss function
        F = reverse_propagation(F, Propagations, DOES);
        
        min_intensity = abs(W).^IntensityFactor;
        min_phase = sum((pi-angle(W.*F)).*min_intensity,4);
        min_intensity = sum(min_intensity,4);
        min_phase = min_phase./min_intensity;
        min_phase(isnan(min_phase))=0;
    
        % updating weights
        DOES = exp(1i*min_phase);

        % data output to the console
        if mod(iter7+batch-1 + ep*P, cycle) == 0
            Accr = Accr/max(cycle,batch)*100;
            accr_graph(end+1) = Accr;
            display(['epoch = ' num2str(ep) '/' num2str(epoch) '; iter = ' num2str(iter7+batch-1) ...
                 '/' num2str(P) '; accr = ' num2str(Accr) '%; time = ' num2str(toc) ';']);
            Accr = 0;
        end
    end
    DOES = exp(1i*angle(DOES));
end


% clearing unnecessary variables
clearvars num num2 iter7 iter8 iter9 ep me mi W F argmax Accr randind min_phase lz tmp_intensity tmp_phase p S I;
if deleted == true
    clearvars epoch P cycle Target batch LossFunc IntensityFactor sce_factor;
else
    deleted = true;
    Target = permute(Target, [1 2 4 3]);
end
