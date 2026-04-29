classdef (Abstract) OptimizerFabric
    methods (Abstract)
        optimizer = generate(N,is_gpu);
    end
end