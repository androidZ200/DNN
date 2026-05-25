classdef AdagradOptimizer < Optimizer
    properties (Access = private)
        epsilon = 1e-8;
        state;
    end

    methods
        function obj = AdagradOptimizer(Mesh, epsilon)
            if nargin > 1
                obj.epsilon = epsilon;
            end
            obj.state = GPUTest(zeros(size(Mesh), 'single'));
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