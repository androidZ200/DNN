% non-gradient learning method

if exist('P', 'var') ~= 1; P = size(Train,3); end
if exist('epoch', 'var') ~= 1; epoch = 1; end
if exist('batch', 'var') ~= 1; batch = 60; end
if exist('LossFunc', 'var') ~= 1; LossFunc = 'SCE'; end
if exist('IntensityFactor', 'var') ~= 1; IntensityFactor = 2; end
if exist('cycle', 'var') ~= 1; cycle = 200; end
if exist('threads', 'var') ~= 1; threads = 0; end
if exist('sce_factor', 'var') ~= 1; sce_factor = 15; end
if exist('deleted', 'var') ~= 1; deleted = true; end

batch = min(batch, P);
cycle = min(cycle, P);
Accr = 0;
lz = size(DOES,3);
randind = randperm(size(Train,3));
randind = randind(1:P);
accr_graph(1) = nan;

% for Gauss Loss Function
if exist('Target', 'var') ~= 1
    Target = gpuArray(zeros(N,N,ln));
    for num=1:ln
        Target(:,:,num) = exp(-((X - coords(num,1)).^2 + (Y - coords(num,2)).^2)/(spixel*7)^2);
        Target(:,:,num) = normalize_field(Target(:,:,num));
    end
end

tic;
for ep=1:epoch
    for iter7=1:batch:P
        min_phase = gpuArray(zeros(N,N,lz));
        min_intensity = gpuArray(zeros(N,N,lz));
        parfor (iter8=0:batch-1, threads)
            num = TrainLabel(randind(iter7+iter8));
            
            % direct propagation
            W = GetImage(Train(:,:,randind(iter7+iter8)));
            [me, W, mi] = recognize(W,Propagations,DOES,MASK,is_max);
            I = sum(me);
            me = me/I;

            if max(me) == me(num)
                Accr = Accr + 1;
            end
            % training
            F = gpuArray(zeros(N));
            W(:,:,end) = conj(W(:,:,end));
            switch LossFunc
                case 'Target' % the integral Gaussian function
                    F = W(:,:,end).*(abs(W(:,:,end)).^2 - Target(:,:,num));
                case 'MSE' % standard deviation
                    S = me;
                    me(num) = me(num) - 1;
                    me = (me - sum(me.*S))/I;
                    for num2=1:ln
                        F = F + W(:,:,end)*me(num2).*mi(:,:,num2);
                    end
                case 'SCE' % softmax cross entropy
                    p = exp(sce_factor*me); 
                    p = p/sum(p);
                    p = p - sum(p.*me) + me(num);
                    p(num) = p(num)-1;
                    p = p*sce_factor/2/I;
                    for num2=1:ln
                        F = F + W(:,:,end)*p(num2).*mi(:,:,num2);
                    end
                otherwise
                    error(['Loss function "' name '" is not exist']);
            end
            % find global minimum of loss function
            F = reverse_propagation(F, Propagations, DOES);
            tmp_phase = pi-angle(W(:,:,1:end-1).*F);
            tmp_intensity = abs(W(:,:,1:end-1)).^IntensityFactor;
            min_phase = min_phase + tmp_phase.*tmp_intensity;
            min_intensity = min_intensity + tmp_intensity;
        end
    
        % updating weights
        min_phase = min_phase./min_intensity;
        min_phase(isnan(min_phase))=0;
        DOES = exp(1i*min_phase);

        % data output to the console
        if mod(iter7+batch-1, cycle) == 0
            Accr = Accr/max(cycle,batch)*100;
            accr_graph(end+1) = Accr;
            display(['epoch = ' num2str(ep) '; iter = ' num2str(iter7+batch-1) '/' num2str(P) ...
                 '; accr = ' num2str(Accr) '%; time = ' num2str(toc) ';']);
            Accr = 0;
        end
    end
    DOES = exp(1i*angle(DOES));
end


% clearing unnecessary variables
clearvars num num2 iter7 iter8 iter9 ep me mi W F argmax Accr randind min_phase lz tmp_intensity tmp_phase p S I;
if deleted == true
    clearvars epoch P cycle Target batch LossFunc IntensityFactor threads sce_factor;
else
    deleted = true;
end
