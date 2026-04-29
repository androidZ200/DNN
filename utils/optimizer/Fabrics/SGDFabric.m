classdef SGDFabric < OptimizerFabric
    methods
        function optimizer = generate(obj,N,is_gpu)
            optimizer = SGDOptimizer();
        end
    end
end