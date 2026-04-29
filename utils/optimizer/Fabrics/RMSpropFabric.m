classdef RMSpropFabric < OptimizerFabric
    properties (Access = private)
        accumulater = 0.999;
        epsilon = 1e-8;
    end

    methods
        function obj = RMSpropFabric(accumulater, epsilon)
            if (nargin > 1)
                obj.accumulater = accumulater;
                obj.epsilon = epsilon;
            end
        end

        function optimizer = generate(obj,N,is_gpu)
            optimizer = RMSpropOptimizer(N,is_gpu,obj.accumulater,obj.epsilon);
        end
    end
end