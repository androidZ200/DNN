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
if exist('threads', 'var') ~= 1; threads = 0; end
if exist('deleted', 'var') ~= 1; deleted = true; end
if exist('DOES_MASK', 'var') ~= 1; DOES_MASK = ones(N,N,length(Propagations)); end
if exist('DOES', 'var') ~= 1; DOES = DOES_MASK; end
if exist('sce_factor', 'var') ~= 1; sce_factor = 15; end


batch = min(batch, P);
Accr = 0;
randind = randperm(size(Train,3));
randind = randind(1:P);
accr_graph(1) = nan;
tmp_data = zeros(N,N,size(DOES,3));

% for Gauss Loss Function
if exist('Target', 'var') ~= 1
    Target = zeros(N,N,ln);
    for num=1:ln
        Target(:,:,num) = exp(-((X - coords(num,1)).^2 + (Y - coords(num,2)).^2)/(spixel*7)^2);
        Target(:,:,num) = normalize_field(Target(:,:,num));
    end
end


tic;
for ep=1:epoch
    for iter7=1:batch:P
        gradient = zeros(N,N,size(DOES,3));
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
            F = zeros(N);
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
            % reverse propagation
            F = reverse_propagation(F, Propagations, DOES);
            gradient = gradient - imag(W(:,:,1:end-1).*F.*DOES);
        end
    
        % updating weights
        [gradient, tmp_data] = criteria(gradient, tmp_data, method, [params, 1+((iter7-1)+P*(ep-1))/batch]);
        DOES = DOES.*exp(-1i*speed*gradient);
        speed = speed*slowdown;

        % data output to the console
        if mod(iter7+batch-1 + ep*P, cycle) == 0
            Accr = Accr/max(cycle,batch)*100;
            accr_graph(end+1) = Accr;
            display(['epoch = ' num2str(ep) '/' num2str(epoch) '; iter = ' num2str(iter7+batch-1) ...
                 '/' num2str(P) '; accr = ' num2str(Accr) '%; time = ' num2str(toc) ';']);
            Accr = 0;
        end
    end
    DOES = DOES_MASK.*exp(1i*angle(DOES));
end

% clearing unnecessary variables
clearvars num num2 iter7 iter8 iter9 ep me mi W F T Accr Target randind gradient p S I;
if deleted == true
    clearvars P epoch speed slowdown batch LossFunc method params cycle deleted Target tmp_data threads sce_factor;
else
    deleted = true;
end
