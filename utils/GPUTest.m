function Array = GPUTest(Array)
    global is_gpu;
    if isempty(is_gpu); is_gpu = false; end
    
    if is_gpu
        Array = gpuArray(Array);
    else
        Array = gather(Array);
    end
end

