classdef NesterovFabric < OptimizerFabric
    properties (Access = private)
        viscosity = 0.9;
    end

    methods
        function obj = NesterovFabric(viscosity)
            if (nargin > 0)
                obj.viscosity = viscosity;
            end
        end

        function optimizer = generate(obj,N,is_gpu)
            optimizer = NesterovOptimizer(N,is_gpu,obj.viscosity);
        end
    end
end