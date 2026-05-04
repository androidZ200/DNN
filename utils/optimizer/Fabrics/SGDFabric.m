classdef SGDFabric < OptimizerFabric
    methods
        function optimizer = generate(obj,Mesh)
            optimizer = SGDOptimizer();
        end
    end
end