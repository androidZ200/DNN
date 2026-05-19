% gradient learning method

if ~exist('Train', 'var'); error('Train database has not loaded'); end
if ~exist('TrainLabel', 'var'); error('TrainLabel has not loaded'); end
if ~exist('OptSystem', 'var'); error('OptSystem has not created'); end

if ~exist('epoch', 'var'); epoch = 1; end
if ~exist('speed', 'var'); error('speed is not define'); end
if ~exist('slowdown', 'var'); slowdown = 1; end
if ~exist('batch', 'var'); error('batch is not define'); end
if ~exist('max_batch', 'var'); max_batch = batch; end
if ~exist('LossFunc', 'var'); error('LossFunc is not define'); end
if ~exist('target', 'var'); target = eye(OptSystem.Output.count_outputs(),length(unique(TrainLabel))); end
if ~exist('cycle', 'var'); cycle = size(Train,3); end

if ~exist('is_backup', 'var'); is_backup = false; end
if ~exist('backup_time', 'var') && is_backup; backup_time = 3600; end

batch = min(batch, size(Train,3));
max_batch = min(batch, max_batch);
target = GPUTest(target);

%% training
tt1 = tic;
tt_backup = tic;
last_backup_time = toc(tt_backup);
loss = 0; accr = 0;
ndisp();

randind = [];
for iter8=1:epoch
    randind = [randind randperm(size(Train,3), size(Train,3))];
end
if ~exist('iter7', 'var'); iter7 = 1-batch; end
for iter7=iter7+batch:batch:length(randind)   
    gradient = [];
    for iter9=0:max_batch:(batch-1)
        index = randind(iter7+iter9+(0:min(max_batch-1, length(randind)-iter7-iter9)));
        num = reshape(TrainLabel(index),1,[]);
        
        % direct propagation
        score = OptSystem.Forward(Train(:,:,index));
        [~, maxind] = max(score);
        accr = accr*0.95 + 0.05*mean(maxind == num);
        % get gradient
        loss = loss*0.95 + 0.05*mean(LossFunc.get_error(score, target(:,num)));
        error = LossFunc.get_gradient(score, target(:,num));
        % back propagation
        gradient = cellsum(OptSystem.Backward(error), gradient);

        
        % display info
        progres = (iter7+iter9+max_batch-1) / length(randind);
        first_line = ['[' num2str(progres*100,'%05.2f') '%]; loss = ' num2str(loss,'%.3e') ...
            '; accr = ' num2str(accr*100,'%.2f') '%'];
        rdisp([first_line '\n' waitbartext(50, progres) ' time = ' num2str(toc(tt1)) ';']);
    end

    % updating weights
    OptSystem.Step(gradient,speed);
    speed = speed*slowdown;
    
    % backup
    if is_backup && toc(tt_backup) - last_backup_time > backup_time
        rdisp('backuping...');
        save('training_backup');
        last_backup_time = toc(tt_backup);
    end

    % data output to the console
    if mod(iter7+batch-1, cycle) == 0
        rdisp(first_line);
        ndisp();
    end
end

%% clearing unnecessary variables

clearvars epoch speed slowdown batch max_batch LossFunc target cycle is_backup backup_time tt1 ...
    tt_backup last_backup_time loss accr randind iter8 iter7 gradient iter9 index num score ...
    maxind error progres first_line;
