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
        function obj = AdamOptimizer(N, is_gpu, viscosity, accumulater, epsilon)
            if nargin > 2
                obj.epsilon = epsilon;
                obj.viscosity = viscosity;
                obj.accumulater = accumulater;
            end
            obj.state_v = zeros(N, 'single');
            obj.state_a = zeros(N, 'single');
            if is_gpu
                obj.state_v = gpuArray(obj.state_v);
                obj.state_a = gpuArray(obj.state_a);
            end
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
    end
end