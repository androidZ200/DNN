classdef RMSpropOptimizer < Optimizer
    properties (Access = private)
        accumulater = 0.999;
        epsilon = 1e-8;
        state;
    end

    methods
        function obj = RMSpropOptimizer(N, is_gpu, accumulater, epsilon)
            if nargin > 2
                obj.epsilon = epsilon;
                obj.accumulater = accumulater;
            end
            obj.state = zeros(N, 'single');
            if is_gpu
                obj.state = gpuArray(obj.state);
            end
        end

        function gradient = optimize(obj,gradient)
            obj.state = obj.accumulater*obj.state + (1 - obj.accumulater)*gradient.^2;
            gradient = gradient./sqrt(obj.state+obj.epsilon);
        end

        function reset(obj)
            obj.state(:) = 0;
        end
    end
end