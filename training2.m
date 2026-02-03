% gradient learning method

if ~exist('P', 'var'); P = size(Train,3); end
if ~exist('epoch', 'var'); epoch = 1; end
if ~exist('speed', 'var'); speed = 1e-1; end
if ~exist('slowdown', 'var'); slowdown = 0.999; end
if ~exist('batch', 'var'); batch = P; end
if ~exist('max_batch', 'var'); max_batch = batch; end
if ~exist('LossFunc', 'var'); LossFunc = 'MSE'; end
if ~exist('sce_factor', 'var') && strcmp(LossFunc, 'SCE'); sce_factor = 500; end
if ~exist('cycle', 'var'); cycle = 200; end
if ~exist('deleted', 'var'); deleted = true; end
if ~exist('MASK', 'var'); MASK = ones(1,1,size(Train,3)); end
if ~exist('max_offsets', 'var'); max_offsets = 0; end
if ~exist('optimizer', 'var'); optimizer = SGD_optimizer(); end
if ~exist('is_backup', 'var'); is_backup = false; end
if ~exist('backup_time', 'var'); backup_time = 3600; end

if disp_info >= 2; ndisp('start training2'); end
batch = min(batch, P);
loss_graph(1) = nan;
max_batch = min(batch, max_batch);

zero_grad = create_cells(N(1:end-1,:),1,'zeros',is_gpu);
W = create_cells(N,max_batch,'zeros',is_gpu);
F = create_cells(N,max_batch,'zeros',is_gpu);

if ~exist('TrainLabel', 'var')
    if size(Target,3) == 1
        TrainLabel = ones(size(Train,3),1);
    elseif size(Target,3) == size(Train,3)
        TrainLabel = (1:size(Target,3)).';
    else
        error('TrainLabel in not exist');
    end
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
    loss = 0;

    % rand offsets
    if max_offsets > 0
        off = randi(3, length(DOES), 2)-2;
        off = off*max_offsets;
        for iter8 = 1:length(DOES)
            DOES{iter8} = circshift(DOES{iter8}, off(iter8,:));
        end
    end
    
    for iter9=0:max_batch:(batch-1)
        num = reshape(TrainLabel(randind(iter7+iter9+(0:max_batch-1))),1,[]);
        
        % direct propagation
        W{1} = GetImage(Train(:,:,randind(iter7+iter9+(0:max_batch-1))));
        for iter8=1:length(W)-1
            W{iter8+1} = FPropagations{iter8}(DOES{iter8}.*W{iter8});
        end

        % error field
        switch LossFunc
            case 'MSE'
                loss = loss + sum(MASK(:,:,num).*(abs(W{end}).^2 - Target(:,:,num)).^2, "all");
                F{end} = 4*conj(W{end}).*MASK(:,:,num).*(abs(W{end}).^2 - Target(:,:,num));
            case 'SCE'
                p = exp(sce_factor*abs(W{end}).^2); p = p./sum(sum(p));
                loss = loss - sum(Target(:,:,num).*log(p), "all");
                F{end} = 2*sce_factor.*conj(W{end}).*(sum(sum(Target(:,:,num))).*p - Target(:,:,num));
        end

        % reverse propagation
        for iter8=length(F)-1:-1:1
            F{iter8} = DOES{iter8}.*BPropagations{iter8}(F{iter8+1});
        end
        gradient = cellfun(@(gr,w,f)gr+sum(w.*f,3), gradient,W(1:end-1),F(1:end-1),'UniformOutput',false);
        
        if disp_info >= 1
            rdisp(['iter = ' num2str(iter7+iter9+max_batch-1) '/' num2str(length(randind)) ...
                '; loss = ' num2str(loss) '; time = ' num2str(toc(tt1)) ';']);
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
    gradient = cellfun(@(DOES,error) DOES.get_gradient(error),DOES,gradient,'UniformOutput',false);
    gradient = optimizer.optimize(gradient);
    cellfun(@(DOES,gradient)DOES.gradient_step(-speed*gradient),DOES,gradient,'UniformOutput',false);
    speed = speed*slowdown;
    
    % backup
    if is_backup && toc(tt_backup) - last_backup_time > backup_time
        if disp_info >= 2; rdisp('backuping...'); end
        save('training_backup');
        last_backup_time = toc(tt_backup);
    end

    % data output to the console
    if mod(iter7+batch-1, cycle) == 0
        loss_graph(end+1) = loss;
        ndisp();
    end
end
clearvars iter7 randind;
if disp_info >= 2; ndisp('training2 finished'); end

%% clearing unnecessary variables

clearvars num iter7 iter8 iter9 ep randind W Wend F loss gradient tt1 d tt_backup last_backup_time zero_grad;
if deleted == true
    clearvars P epoch speed slowdown batch cycle deleted optimizer max_offsets is_backup backup_time LossFunc;
else
    deleted = true;
end
