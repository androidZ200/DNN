classdef NesterovOptimizer < Optimizer
    properties (Access = private)
        viscosity = 0.9;
        state;
    end

    methods
        function obj = NesterovOptimizer(N, is_gpu, viscosity)
            if nargin > 2
                obj.viscosity = viscosity;
            end
            obj.state = zeros(N, 'single');
            if is_gpu
                obj.state = gpuArray(obj.state);
            end
        end

        function gradient = optimize(obj,gradient)
            obj.state = obj.viscosity*obj.state + (1 - obj.viscosity)*gradient;
            gradient = obj.state;
        end

        function reset(obj)
            obj.state(:) = 0;
        end
    end
end