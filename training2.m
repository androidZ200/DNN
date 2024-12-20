% gradient learning method

if ~exist('P', 'var'); P = size(Train,3); end
if ~exist('epoch', 'var'); epoch = 1; end
if ~exist('speed', 'var'); speed = 1e-1; end
if ~exist('slowdown', 'var'); slowdown = 0.999; end
if ~exist('batch', 'var'); batch = 20; end
if ~exist('max_batch', 'var'); max_batch = batch; end
if ~exist('method', 'var'); method = 'SGD'; end
if ~exist('params', 'var'); params = []; end
if ~exist('cycle', 'var'); cycle = 200; end
if ~exist('deleted', 'var'); deleted = true; end
if ~exist('MASK', 'var'); MASK = ones(size(Target),'single'); end
if ~exist('max_offsets', 'var'); max_offsets = 0; end
if ~exist('iter_gradient', 'var'); iter_gradient = 0; end
if ~exist('is_backup', 'var'); is_backup = false; end
if ~exist('backup_time', 'var'); backup_time = 3600; end

batch = min(batch, P);
loss_graph(1) = nan;
max_batch = min(batch, max_batch);

for iter8=1:length(FPropagations)
    if ~exist('tmp_data', 'var') || length(tmp_data) < iter8; tmp_data{iter8,1} =  zeros(size(DOES{iter8}),'single'); end
    zero_grad{iter8,1} = zeros(size(DOES{iter8}),'single');
    W{iter8,1} = zeros([N(iter8,:),batch],'single');
    F{iter8,1} = zeros([N(iter8,:),batch],'single');
end
W{length(FPropagations)+1} = zeros([N(end,:),batch],'single');
F{length(FPropagations)+1} = zeros([N(end,:),batch],'single');

% GPU_CPU;

%% training
tt1 = tic;
tt_backup = tic;
last_backup_time = toc(tt_backup);
ndisp();
if ~exist('ep', 'var'); ep = 1; end
for ep=ep:epoch
    if ~exist('randind', 'var')
        randind = randperm(size(Train,3));
        randind = randind(1:P);
    end
    if ~exist('iter7', 'var'); iter7 = 1-batch; end
    for iter7=iter7+batch:batch:P
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
            num = TrainLabel(randind(iter7+iter9+(0:max_batch-1)))';
            
            % direct propagation
            W{1} = GetImage(Train(:,:,randind(iter7+iter9+(0:max_batch-1))));
            for iter8=1:length(W)-1
                W{iter8+1} = FPropagations{iter8}(W{iter8}.*DOES{iter8});
            end

            % error field
            Wend = conj(W{end});
            F{end} = 4*Wend.*MASK.*(abs(Wend).^2 - Target(:,:,num));
            loss = loss + sum(MASK.*(abs(Wend).^2 - Target(:,:,num)).^2, "all");

            % reverse propagation
            for iter8=length(F)-1:-1:1
                F{iter8} = BPropagations{iter8}(F{iter8+1}).*DOES{iter8};
            end
            gradient = cellfun(@(gr,w,f)gr-imag(sum(w.*f,3)), gradient,W(1:end-1),F(1:end-1),'UniformOutput',false);
            
            rdisp(['iter = ' num2str(iter7+iter9+max_batch-1 + (ep-1)*P) '/' num2str(P*epoch) ...
                '; loss = ' num2str(loss) '; time = ' num2str(toc(tt1)) ';']);
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
        DOES = cellfun(@(DOES,gradient)DOES.*exp(-1i*speed*gradient), DOES,gradient,'UniformOutput',false);
        speed = speed*slowdown;
        
        % backup
        if is_backup && toc(tt_backup) - last_backup_time > backup_time
            rdisp('backuping...');
            save('training_backup');
            last_backup_time = toc(tt_backup);
        end

        % data output to the console
        if mod(iter7+batch-1 + (ep-1)*P, cycle) == 0
            loss_graph(end+1) = loss;
            ndisp();
        end
    end
    clearvars iter7 randind;
    DOES = cellfun(@(DM,D)DM.*exp(1i*angle(D)), DOES_MASK,DOES,'UniformOutput',false);
end

%% clearing unnecessary variables

clearvars num iter7 iter8 iter9 ep randind W Wend F loss gradient tt1 d tt_backup last_backup_time zero_grad;
if deleted == true
    clearvars P epoch speed slowdown batch method params cycle deleted tmp_data ...
        iter_gradient max_offsets is_backup backup_time;
else
    deleted = true;
end
