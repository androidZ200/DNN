classdef AdagradOptimizer < Optimizer
    properties (Access = private)
        epsilon = 1e-8;
        state;
    end

    methods
        function obj = AdagradOptimizer(N, is_gpu, epsilon)
            if nargin > 2
                obj.epsilon = epsilon;
            end
            obj.state = zeros(N, 'single');
            if is_gpu
                obj.state = gpuArray(obj.state);
            end
        end

        function gradient = optimize(obj,gradient)
            obj.state = obj.state+gradient.^2;
            gradient = gradient./sqrt(obj.state+obj.epsilon);
        end

        function reset(obj)
            obj.state(:) = 0;
        end
    end
end