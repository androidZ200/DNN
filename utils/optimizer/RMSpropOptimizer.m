classdef RMSpropOptimizer < Optimizer
    properties (Access = private)
        accumulater = 0.999;
        epsilon = 1e-8;
        state;
    end

    methods
        function obj = RMSpropOptimizer(Mesh, accumulater, epsilon)
            if nargin > 1
                obj.epsilon = epsilon;
                obj.accumulater = accumulater;
            end
            obj.state = GPUTest(zeros(size(Mesh), 'single'));
        end

        function gradient = optimize(obj,gradient)
            obj.state = obj.accumulater*obj.state + (1 - obj.accumulater)*gradient.^2;
            gradient = gradient./sqrt(obj.state+obj.epsilon);
        end
        function reset(obj)
            obj.state(:) = 0;
        end
        function obj = circshift(obj, N)
            obj.state = circshift(obj.state, N);
        end
    end
end