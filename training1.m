% gradient learning method

if exist('P', 'var') ~= 1; P = size(Train,3); end
if exist('epoch', 'var') ~= 1; epoch = 1; end
if exist('speed', 'var') ~= 1; speed = 1e-1; end
if exist('slowdown', 'var') ~= 1; slowdown = 0.999; end
if exist('batch', 'var') ~= 1; batch = 20; end
if exist('max_batch', 'var') ~= 1; max_batch = 20; end
if exist('LossFunc', 'var') ~= 1; LossFunc = 'SCE'; end
if exist('method', 'var') ~= 1; method = 'SGD'; end
if exist('params', 'var') ~= 1; params = []; end
if exist('cycle', 'var') ~= 1; cycle = 200; end
if exist('deleted', 'var') ~= 1; deleted = true; end
if exist('DOES_MASK', 'var') ~= 1; DOES_MASK = ones(N,N,length(Propagations),'single'); end
if exist('DOES', 'var') ~= 1; DOES = DOES_MASK; end
if exist('sce_factor', 'var') ~= 1; sce_factor = 80; end
if exist('sosh_factor', 'var') ~= 1; sosh_factor = 10; end
if exist('target_scores', 'var') ~= 1; target_scores = eye(size(MASK,3),ln,'single'); end
if exist('max_offsets', 'var') ~= 1; max_offsets = 0; end
if exist('iter_gradient', 'var') ~= 1; iter_gradient = 0; end
if exist('tmp_data', 'var') ~= 1; tmp_data =  zeros(N,N,size(DOES,3),'single'); end

batch = min(batch, P);
Accr = 0;
Aint = 0;
accr_graph(1) = nan;
aint_graph(1) = nan;
DOES = single(DOES);
DOES_MASK = single(DOES_MASK);
gradient = zeros(size(DOES), 'single');
tmp_data = single(tmp_data);
W = zeros(N,N,length(Propagations)+1,min(batch, max_batch));
F = zeros(N,N,length(Propagations)+1,min(batch, max_batch));
if (~is_max); MASK = repmat(MASK, [1 1 1 min(batch, max_batch)]); end

% for Gauss Loss Function
if strcmp(LossFunc, 'Target')
    if exist('Target', 'var') ~= 1
        Target = ((X - permute(coords(:,1), [3 2 1])).^2 + (Y - permute(coords(:,2), [3 2 1])).^2)/(spixel*7)^2;
        Target = normalize_field(exp(-Target)).^2;
    end
    Target = single(permute(Target, [1 2 4 3]));
end

GPU_CPU;

%% training
tt1 = tic;
for ep=1:epoch
    randind = randperm(size(Train,3));
    randind = randind(1:P);
    for iter7=1:batch:P
        gradient(:) = 0;

        % rand offsets
        if max_offsets > 0
            off = randi(max_offsets*2+1, size(DOES,3), 2)-max_offsets-1;
            for iter8 = 1:size(DOES,3)
                DOES(:,:,iter8) = circshift(DOES(:,:,iter8), off(iter8,:));
                tmp_data(:,:,iter8) = circshift(tmp_data(:,:,iter8), off(iter8,:));
            end
        end

        for iter9=0:min(batch, max_batch):(batch-1)
            num = TrainLabel(randind(iter7+iter9+(0:min(batch, max_batch)-1)))';
            
            % direct propagation
            W(:,:,1,:) = GetImage(Train(:,:,randind(iter7+iter9+(0:min(batch, max_batch)-1))));
            for iter8=1:size(W,3)-1
                W(:,:,iter8+1,:) = Propagations{iter8}(W(:,:,iter8,:).*DOES(:,:,iter8));
            end
            [me, mi] = get_scores(W(:,:,end,:), MASK, is_max);
            I = sum(me);
            me = me./I;
            Accr = Accr + sum(max(me) == me(num+(0:min(batch, max_batch)-1)*size(MASK,3)));
            sortme = sort(me);
            Aint = Aint + sum((sortme(end,:)-sortme(end-1,:))./(sortme(end,:)+sortme(end-1,:)));
            
            % training
            Wend = conj(W(:,:,end,:));
            switch LossFunc
                case 'Target' % the integral Target function
                    F(:,:,end,:) = 4*Wend.*(abs(Wend).^2 - Target(:,:,1,num));
                case 'Sosh'
                    p = me >= me(num+(0:min(batch, max_batch)-1)*size(MASK,3));
                    p = -(sum(me.*p)./sum(p) - me).*p;
                    d = sqrt(sum(p.^2));
                    p = p./d.*exp(-d*sosh_factor); p(isnan(p)) = 0;
                    p = 2*(p-sum(me.*p))./I;
                    F(:,:,end,:) = Wend.*sum(permute(p,[3 4 1 2]).*mi,3);
                case 'MSE' % mean squared error
                    p = me - target_scores(:,num);
                    p = 4*(p-sum(me.*p))./I;
                    F(:,:,end,:) = Wend.*sum(permute(P,[3 4 1 2]).*mi,3);
                case 'MAE' % mean absolute error
                    p = me - target_scores(:,num);
                    p = p ./ abs(p); p(isnan(p)) = 0;
                    p = 2*(p-sum(me.*p))./I;
                    F(:,:,end,:) = Wend.*sum(permute(p,[3 4 1 2]).*mi,3);
                case 'SCE' % softmax cross entropy
                    p = exp(sce_factor*me); 
                    p = p./sum(p);
                    alpha = target_scores(:,num);
                    p = (p-sum(p.*me)).*sum(alpha) + sum(alpha.*me) - alpha;
                    p = p*sce_factor*2./I;
                    F(:,:,end,:) = Wend.*sum(permute(p,[3 4 1 2]).*mi,3);
                otherwise
                    error(['Loss function "' name '" is not exist']);
            end
            % reverse propagation
            for iter8=size(F,3)-1:-1:1
                F(:,:,iter8,:) = Propagations{iter8}(F(:,:,iter8+1,:)).*DOES(:,:,iter8);
            end
            gradient = gradient - imag(sum(W(:,:,1:end-1,:).*F(:,:,1:end-1,:), 4));
        end

        % updating weights
        iter_gradient = iter_gradient + 1;
        [gradient, tmp_data] = criteria(gradient, tmp_data, method, [params, iter_gradient]);
        DOES = DOES.*exp(-1i*speed*gradient);
        speed = speed*slowdown;

        % reverse offsets
        if max_offsets > 0
            for iter8 = 1:size(DOES,3)
                DOES(:,:,iter8) = circshift(DOES(:,:,iter8), -off(iter8,:));
                tmp_data(:,:,iter8) = circshift(tmp_data(:,:,iter8), -off(iter8,:));
            end
        end
        
        % data output to the console
        if mod(iter7+batch-1 + ep*P, cycle) == 0
            Accr = Accr/max(cycle,batch)*100;
            Aint = Aint/max(cycle,batch)*100;
            accr_graph(end+1) = Accr;
            aint_graph(end+1) = Aint;

            disp(['iter = ' num2str(iter7+batch-1 + (ep-1)*P) '/' num2str(P*epoch) ...
                '; accr = ' num2str(Accr) '%; time = ' num2str(toc(tt1)) ';']);
            Accr = 0;
            Aint = 0;
        end
    end
    DOES = DOES_MASK.*exp(1i*angle(DOES));
end

%% clearing unnecessary variables

if (~is_max); MASK = MASK(:,:,:,1); end
clearvars num iter7 iter8 iter9 ep me mi W Wend F sortme Accr Aint randind gradient p I alpha tt1 d;
if deleted == true
    clearvars P epoch speed slowdown batch LossFunc method params cycle deleted Target tmp_data ...
        sce_factor target_scores iter_gradient DOES_MASK max_offsets sosh_factor;
else
    deleted = true;
    if strcmp(LossFunc, 'Target')
        Target = permute(Target, [1 2 4 3]);
    end
end
