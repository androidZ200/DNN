classdef Adam_optimizer < Optimizer
    properties (Access = private)
        viscosity = 0.9;
        accumulater = 0.999;
        epsilon = 1e-8;
        iteration = 0;
        state_v;
        state_a;
    end

    methods
        function obj = Adam_optimizer(N, is_gpu, viscosity, accumulater, epsilon)
            if nargin > 2
                obj.epsilon = epsilon;
                obj.viscosity = viscosity;
                obj.accumulater = accumulater;
            end
            obj.state_v = create_cells(N(1:end-1,:),1,'zeros',is_gpu);
            obj.state_a = create_cells(N(1:end-1,:),1,'zeros',is_gpu);
        end

        function gradient = optimize(obj,gradient)
            obj.state_v = cellfun(@(state_v,grad)obj.viscosity*state_v + (1 - obj.viscosity)*grad, ...
                obj.state_v,gradient,'UniformOutput',false);
            obj.state_a = cellfun(@(state_a,grad)obj.accumulater*state_a + (1 - obj.accumulater)*grad.^2, ...
                obj.state_a,gradient,'UniformOutput',false);
            obj.iteration = obj.iteration + 1;

            gradient = cellfun(@(state_v, state_a)state_v/(1 - obj.viscosity^obj.iteration)./ ...
                (sqrt(state_a/(1 - obj.accumulater^obj.iteration)) + obj.epsilon), ...
                obj.state_v,obj.state_a,'UniformOutput',false);
        end
    end
end