if(exist('is_gpu', 'var'))
    if(is_gpu)
        if(exist('DOES', 'var')); DOES = gpuArray(DOES); end
        if(exist('X', 'var')); X = gpuArray(X); end
        if(exist('Y', 'var')); Y = gpuArray(Y); end
        if(exist('U', 'var')); U = gpuArray(U); end
        if(exist('Test', 'var')); Test = gpuArray(Test); end
        if(exist('TestLabel', 'var')); TestLabel = gpuArray(TestLabel); end
        if(exist('Train', 'var')); Train = gpuArray(Train); end
        if(exist('TrainLabel', 'var')); TrainLabel = gpuArray(TrainLabel); end
        if(exist('MASK', 'var')); MASK = gpuArray(MASK); end
        if(exist('W', 'var')); W = gpuArray(W); end
        if(exist('F', 'var')); F = gpuArray(F); end
        if(exist('DOES_MASK', 'var')); DOES_MASK = gpuArray(DOES_MASK); end
        if(exist('tmp_data', 'var')); tmp_data = gpuArray(tmp_data); end
        if(exist('Target', 'var')); Target = gpuArray(Target); end
        if(exist('target_scores', 'var')); target_scores = gpuArray(target_scores); end
    else
        if(exist('DOES', 'var')); DOES = gather(DOES); end
        if(exist('X', 'var')); X = gather(X); end
        if(exist('Y', 'var')); Y = gather(Y); end
        if(exist('U', 'var')); U = gather(U); end
        if(exist('Test', 'var')); Test = gather(Test); end
        if(exist('TestLabel', 'var')); TestLabel = gather(TestLabel); end
        if(exist('Train', 'var')); Train = gather(Train); end
        if(exist('TrainLabel', 'var')); TrainLabel = gather(TrainLabel); end
        if(exist('MASK', 'var')); MASK = gather(MASK); end
        if(exist('W', 'var')); W = gather(W); end
        if(exist('F', 'var')); F = gather(F); end
        if(exist('DOES_MASK', 'var')); DOES_MASK = gather(DOES_MASK); end
        if(exist('tmp_data', 'var')); tmp_data = gather(tmp_data); end
        if(exist('Target', 'var')); Target = gather(Target); end
        if(exist('target_scores', 'var')); target_scores = gather(target_scores); end
    end
end