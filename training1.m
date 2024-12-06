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
if ~exist('DOES_MASK', 'var'); DOES_MASK = ones(N,N,length(Propagations),'single'); end
if ~exist('DOES', 'var'); DOES = DOES_MASK; end
if ~exist('sce_factor', 'var') && strcmp(LossFunc, 'SCE'); sce_factor = 80; end
if ~exist('sosh_factor', 'var') && strcmp(LossFunc, 'Sosh'); sosh_factor = 10; end
if ~exist('target_scores', 'var'); target_scores = eye(size(MASK,3),ln,'single'); end
if ~exist('max_offsets', 'var'); max_offsets = 0; end
if ~exist('iter_gradient', 'var'); iter_gradient = 0; end
if ~exist('tmp_data', 'var'); tmp_data =  zeros(size(DOES),'single'); end
if ~exist('is_backup', 'var'); is_backup = false; end
if ~exist('backup_time', 'var') && is_backup; backup_time = 3600; end


batch = min(batch, P);
if ~exist('Accr', 'var'); Accr = 0; end
if ~exist('Aint', 'var'); Aint = 0; end
accr_graph(1) = nan;
aint_graph(1) = nan;
DOES = single(DOES);
DOES_MASK = single(DOES_MASK);
gradient = zeros(size(DOES), 'single');
tmp_data = single(tmp_data);
W = zeros(size(DOES,1),size(DOES,2),length(Propagations)+1,min(batch, max_batch));
F = zeros(size(DOES,1),size(DOES,2),length(Propagations)+1,min(batch, max_batch));

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
            [me, mi] = get_scores(W(:,:,end,:), MASK, is_max);
            I = sum(me);
            me = me./I;
            Accr = Accr + sum(max(me) == me(num+(0:min(batch, max_batch)-1)*size(MASK,3)));
            sortme = sort(me);
            if(size(me,1)>1)
                Aint = Aint + sum((sortme(end,:)-sortme(end-1,:))./(sortme(end,:)+sortme(end-1,:)));
            end

            % training
            Wend = conj(W(:,:,end,:));
            switch LossFunc
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
                    F(:,:,end,:) = Wend.*sum(permute(p,[3 4 1 2]).*mi,3);
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

            rdisp(['iter = ' num2str(iter7+iter9+min(batch, max_batch)-1 + (ep-1)*P) '/' num2str(P*epoch) '; accr = ' ...
                num2str(Accr/(mod(iter7+iter9+min(batch, max_batch)+ep*P-2,cycle)+1)*100) ...
                '%; time = ' num2str(toc(tt1)) ';']);
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
            Accr = Accr/max(cycle,batch)*100;
            Aint = Aint/max(cycle,batch)*100;
            accr_graph(end+1) = Accr;
            aint_graph(end+1) = Aint;
            ndisp();
            Accr = 0;
            Aint = 0;
        end
    end
    clearvars iter7 randind;
    DOES = DOES_MASK.*exp(1i*angle(DOES));
end

%% clearing unnecessary variables

clearvars num iter7 iter8 iter9 ep randind me mi W Wend F sortme Accr Aint gradient p I alpha tt1 d ...
    tt_backup last_backup_time;
if deleted == true
    clearvars P epoch speed slowdown batch LossFunc method params cycle deleted tmp_data ...
        sce_factor target_scores iter_gradient DOES_MASK max_offsets sosh_factor is_backup backup_time;
else
    deleted = true;
end
