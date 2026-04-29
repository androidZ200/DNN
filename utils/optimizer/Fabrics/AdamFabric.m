classdef AdamFabric < OptimizerFabric
    properties (Access = private)
        viscosity = 0.9;
        accumulater = 0.999;
        epsilon = 1e-8;
    end

    methods
        function obj = AdamFabric(viscosity, accumulater, epsilon)
            if (nargin > 2)
                obj.viscosity = viscosity;
                obj.accumulater = accumulater;
                obj.epsilon = epsilon;
            end
        end

        function optimizer = generate(obj,N,is_gpu)
            optimizer = AdamOptimizer(N,is_gpu,obj.viscosity,obj.accumulater,obj.epsilon);
        end
    end
end