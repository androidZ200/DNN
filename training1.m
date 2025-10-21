% gradient learning method

if ~exist('P', 'var'); P = size(Train,3); end
if ~exist('epoch', 'var'); epoch = 1; end
if ~exist('speed', 'var'); speed = 1e-1; end
if ~exist('slowdown', 'var'); slowdown = 0.999; end
if ~exist('batch', 'var'); batch = 20; end
if ~exist('max_batch', 'var'); max_batch = batch; end
if ~exist('LossFunc', 'var'); LossFunc = 'SCE'; end
if ~exist('method', 'var'); method = 'SGD'; end
if ~exist('params', 'var'); params = []; end
if ~exist('cycle', 'var'); cycle = 200; end
if ~exist('deleted', 'var'); deleted = true; end
if ~exist('sce_factor', 'var') && strcmp(LossFunc, 'SCE'); sce_factor = 80; end
if ~exist('sosh_factor', 'var') && strcmp(LossFunc, 'Sosh'); sosh_factor = 10; end
if ~exist('joint_factor', 'var'); joint_factor = 0; end
if ~exist('target_scores', 'var'); target_scores = eye(size(MASK,3),ln,'single'); end
if ~exist('max_offsets', 'var'); max_offsets = 0; end
if ~exist('iter_gradient', 'var'); iter_gradient = 0; end
if ~exist('is_backup', 'var'); is_backup = false; end
if ~exist('backup_time', 'var') && is_backup; backup_time = 3600; end
if ~exist('Accr', 'var'); Accr = 0; end
if ~exist('cAccr', 'var'); cAccr = 0; end

if disp_info >= 2; ndisp('start training1'); end
batch = min(batch, P);
accr_graph(1) = nan;
max_batch = min(batch, max_batch);

if ~exist('tmp_data', 'var'); tmp_data = create_cells(N(1:end-1,:),'zeros',is_gpu); end
zero_grad = create_cells(N(1:end-1,:),'zeros',is_gpu);
W = create_cells(N,'zeros',is_gpu);
F = create_cells(N,'zeros',is_gpu);

for iter=1:length(F)
    deep_grad = iter;
    if sum(sum(GRAD_MASK{iter})) > 0; break; end
end

%% training
tt1 = tic;
tt_backup = tic;
last_backup_time = toc(tt_backup);
if disp_info >= 1; ndisp(); end
randind = [];
for iter8=1:epoch
    randind = [randind randperm(size(Train,3), P)];
end
if ~exist('iter7', 'var'); iter7 = 1-batch; end
for iter7=iter7+batch:batch:length(randind)
    gradient = zero_grad;

    % rand offsets
    if max_offsets > 0
        off = randi(3, length(DOES), 2)-2;
        off = off*max_offsets;
        for iter8 = 1:size(DOES,3)
            DOES{iter8} = circshift(DOES{iter8}, off(iter8,:));
        end
    end
    
    for iter9=0:max_batch:(batch-1)
        index = randind(iter7+iter9+(0:min(max_batch-1, length(randind)-iter7-iter9)));
        num = reshape(TrainLabel(index),1,[]);
        
        % direct propagation
        W{1} = GetImage(Train(:,:,index));
        for iter8=1:length(W)-1
            W{iter8+1} = FPropagations{iter8}(W{iter8}.*DOES{iter8});
        end
        [me, mi] = get_scores(permute(W{end},[1 2 4 3]), MASK, is_max);
        I = sum(me);
        me = me./I;
        Accr = Accr + sum(max(me) == me(num+(0:min(max_batch-1, length(randind)-iter7-iter9))*size(MASK,3)));
        cAccr = cAccr + min(max_batch, length(randind)-iter7-iter9+1);

        % training
        Wend = conj(W{end});
        switch LossFunc
            case 'Sosh'
                p = me >= me(num+(0:min(max_batch-1, length(randind)-iter7-iter9))*size(MASK,3));
                p = -(sum(me.*p)./sum(p) - me).*p;
                d = sqrt(sum(p.^2));
                p = p./d.*exp(-d*sosh_factor); p(isnan(p)) = 0;
                p = 2*(p-sum(me.*p))./I;
            case 'MSE' % mean squared error
                p = me - target_scores(:,num);
                p = 4*(p-sum(me.*p))./I;
            case 'MAE' % mean absolute error
                p = me - target_scores(:,num);
                p = p ./ abs(p); p(isnan(p)) = 0;
                p = 2*(p-sum(me.*p))./I;
            case 'SCE' % softmax cross entropy
                p = exp(sce_factor*me); 
                p = p./sum(p);
                alpha = target_scores(:,num);
                p = (p-sum(p.*me)).*sum(alpha) + sum(alpha.*me) - alpha;
                p = p*sce_factor*2./I;
            otherwise
                error(['Loss function "' name '" is not exist']);
        end
        F{end} = Wend.*permute(sum(permute(p,[3 4 1 2]).*mi,3),[1 2 4 3]);
        if joint_factor > 0
            F{end} = (1-joint_factor)*F{end} - 2*joint_factor./permute(I, [1 3 2]).*Wend.*sum(MASK,3);
        end

        % reverse propagation
        for iter8=length(F)-1:-1:deep_grad
            F{iter8} = BPropagations{iter8}(F{iter8+1}).*DOES{iter8};
        end
        gradient = cellfun(@(gr,w,f)gr-imag(sum(w.*f,3)), gradient,W(1:end-1),F(1:end-1),'UniformOutput',false);

        if disp_info >= 1
            rdisp(['iter = ' num2str(iter7+iter9+max_batch-1) '/' num2str(length(randind)) '; accr = ' ...
                num2str(Accr/cAccr*100) ...
                '%; time = ' num2str(toc(tt1)) ';']);
        end
    end

    % reverse offsets
    if max_offsets > 0
        for iter8 = 1:length(DOES)
            DOES{iter8} = circshift(DOES{iter8}, -off(iter8,:));
            gradient{iter8} = circshift(gradient{iter8}, -off(iter8,:));
        end
    end

    % updating weights
    iter_gradient = iter_gradient + 1;
    [gradient, tmp_data] = criteria(gradient, tmp_data, method, [params, iter_gradient]);
    DOES = cellfun(@(DOES,gradient,GRAD_MASK)DOES.*exp(-1i*speed*gradient.*GRAD_MASK), ...
        DOES,gradient,GRAD_MASK,'UniformOutput',false);
    speed = speed*slowdown;
    
    % backup
    if is_backup && toc(tt_backup) - last_backup_time > backup_time
        if disp_info >= 2; rdisp('backuping...'); end
        save('training_backup');
        last_backup_time = toc(tt_backup);
    end

    % data output to the console
    if mod(iter7+batch-1, cycle) == 0
        Accr = Accr/cAccr*100;
        accr_graph(end+1) = Accr;
        Accr = 0; cAccr = 0;
        ndisp();
    end
end
if disp_info >= 2; ndisp('training1 finished'); end

%% clearing unnecessary variables

clearvars num iter7 iter8 iter9 randind me mi W Wend F Accr cAccr gradient p I alpha tt1 ...
    d tt_backup last_backup_time index zero_grad deep_grad;
if deleted == true
    clearvars P epoch speed slowdown batch LossFunc method params cycle deleted tmp_data ...
        sce_factor joint_factor target_scores iter_gradient max_offsets sosh_factor is_backup backup_time;
else
    deleted = true;
end
