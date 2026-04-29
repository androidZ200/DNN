classdef AdagradFabric < OptimizerFabric
    properties (Access = private)
        epsilon = 1e-8;
    end

    methods
        function obj = AdagradFabric(epsilon)
            if (nargin > 0)
                obj.epsilon = epsilon;
            end
        end

        function optimizer = generate(obj,N,is_gpu)
            optimizer = AdagradOptimizer(N,is_gpu,obj.epsilon);
        end
    end
end