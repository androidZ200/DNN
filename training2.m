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
if ~exist('DOES_MASK', 'var'); DOES_MASK = ones(N,N,length(Propagations),'single'); end
if ~exist('DOES', 'var'); DOES = DOES_MASK; end
if ~exist('MASK', 'var'); MASK = ones(size(Target)); end
if ~exist('max_offsets', 'var'); max_offsets = 0; end
if ~exist('iter_gradient', 'var'); iter_gradient = 0; end
if ~exist('tmp_data', 'var'); tmp_data =  zeros(N,N,size(DOES,3),'single'); end
if ~exist('is_backup', 'var'); is_backup = false; end
if ~exist('backup_time', 'var'); backup_time = 3600; end


batch = min(batch, P);
DOES = single(DOES);
DOES_MASK = single(DOES_MASK);
loss_graph(1) = nan;
gradient = zeros(size(DOES), 'single');
tmp_data = single(tmp_data);
W = zeros(N,N,length(Propagations)+1,min(batch, max_batch));
F = zeros(N,N,length(Propagations)+1,min(batch, max_batch));

GPU_CPU;

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
        gradient(:) = 0;
        loss = 0;

        % rand offsets
        if max_offsets > 0
            off = randi(3, size(DOES,3), 2)-2;
            off = off*max_offsets;
            for iter8 = 1:size(DOES,3)
                DOES(:,:,iter8) = circshift(DOES(:,:,iter8), off(iter8,:));
            end
        end
        
        for iter9=0:min(batch, max_batch):(batch-1)
            num = TrainLabel(randind(iter7+iter9+(0:min(batch, max_batch)-1)))';
            
            % direct propagation
            W(:,:,1,:) = GetImage(Train(:,:,randind(iter7+iter9+(0:min(batch, max_batch)-1))));
            for iter8=1:size(W,3)-1
                W(:,:,iter8+1,:) = Propagations{iter8}(W(:,:,iter8,:).*DOES(:,:,iter8));
            end

            % error field
            Wend = conj(W(:,:,end,:));
            F(:,:,end,:) = 4*Wend.*MASK.*(abs(Wend).^2 - Target(:,:,1,num));
            loss = loss + sum(MASK.*(abs(Wend).^2 - Target(:,:,1,num)).^2, "all");

            % reverse propagation
            for iter8=size(F,3)-1:-1:1
                F(:,:,iter8,:) = Propagations{iter8}(F(:,:,iter8+1,:)).*DOES(:,:,iter8);
            end
            gradient = gradient - imag(sum(W(:,:,1:end-1,:).*F(:,:,1:end-1,:), 4));
            
            rdisp(['iter = ' num2str(iter7+batch-1 + (ep-1)*P) '/' num2str(P*epoch) ...
                '; loss = ' num2str(loss) '; time = ' num2str(toc(tt1)) ';']);
        end

        % reverse offsets
        if max_offsets > 0
            for iter8 = 1:size(DOES,3)
                DOES(:,:,iter8) = circshift(DOES(:,:,iter8), -off(iter8,:));
                gradient(:,:,iter8) = circshift(gradient(:,:,iter8), -off(iter8,:));
            end
        end

        % updating weights
        iter_gradient = iter_gradient + 1;
        [gradient, tmp_data] = criteria(gradient, tmp_data, method, [params, iter_gradient]);
        DOES = DOES.*exp(-1i*speed*gradient);
        speed = speed*slowdown;
        
        % backup
        if is_backup && toc(tt_backup) - last_backup_time > backup_time
            rdisp('backuping...');
            save('training_backup');
            last_backup_time = toc(tt_backup);
        end

        % data output to the console
        if mod(iter7+batch-1 + ep*P, cycle) == 0
            loss_graph(end+1) = loss;
            ndisp();
        end
    end
    clearvars iter7 randind;
    DOES = DOES_MASK.*exp(1i*angle(DOES));
end

%% clearing unnecessary variables

clearvars num iter7 iter8 iter9 ep randind W Wend F loss gradient tt1 d tt_backup last_backup_time;
if deleted == true
    clearvars P epoch speed slowdown batch method params cycle deleted tmp_data ...
        iter_gradient DOES_MASK max_offsets is_backup backup_time;
else
    deleted = true;
end
