function Array = GPUTest(Array)
    global is_gpu;
    if is_gpu
        Array = gpuArray(Array);
    else
        Array = gather(Array);
    end
end

