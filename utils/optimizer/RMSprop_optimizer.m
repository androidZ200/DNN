classdef RMSprop_optimizer < Optimizer
    properties (Access = private)
        accumulater = 0.999;
        epsilon = 1e-8;
        state;
    end

    methods
        function obj = RMSprop_optimizer(N, is_gpu, accumulater, epsilon)
            if nargin > 2
                obj.epsilon = epsilon;
                obj.accumulater = accumulater;
            end
            obj.state = create_cells(N(1:end-1,:),1,'zeros',is_gpu);
        end

        function gradient = optimize(obj,gradient)
            obj.state = cellfun(@(state,grad)obj.accumulater*state + (1 - obj.accumulater)*grad.^2, ...
                obj.state,gradient,'UniformOutput',false);
            gradient = cellfun(@(state,grad)grad./sqrt(state+obj.epsilon), obj.state,gradient,'UniformOutput',false);
        end
    end
end