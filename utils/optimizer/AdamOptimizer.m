classdef AdamOptimizer < Optimizer
    properties (Access = private)
        viscosity = 0.9;
        accumulater = 0.999;
        epsilon = 1e-8;
        iteration = 0;
        state_v;
        state_a;
    end

    methods
        function obj = AdamOptimizer(Mesh, viscosity, accumulater, epsilon)
            if nargin > 1
                obj.epsilon = epsilon;
                obj.viscosity = viscosity;
                obj.accumulater = accumulater;
            end
            obj.state_v = GPUTest(zeros(size(Mesh), 'single'));
            obj.state_a = GPUTest(zeros(size(Mesh), 'single'));
        end
        function gradient = optimize(obj,gradient)
            obj.state_v = obj.viscosity*obj.state_v + (1 - obj.viscosity)*gradient;
            obj.state_a = obj.accumulater*obj.state_a + (1 - obj.accumulater)*gradient.^2;
            obj.iteration = obj.iteration + 1;

            gradient = obj.state_v/(1 - obj.viscosity^obj.iteration)./ ...
                (sqrt(obj.state_a/(1 - obj.accumulater^obj.iteration)) + obj.epsilon);
        end
        function reset(obj)
            obj.iteration = 0;
            obj.state_v(:) = 0;
            obj.state_a(:) = 0;
        end
        function obj = circshift(obj, N)
            obj.state_v = circshift(obj.state_v, N);
            obj.state_a = circshift(obj.state_a, N);
        end
    end
end