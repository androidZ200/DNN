classdef Adagrad_optimizer < Optimizer
    properties (Access = private)
        epsilon = 1e-8;
        state;
    end

    methods
        function obj = Adagrad_optimizer(N, is_gpu, epsilon)
            if nargin > 2
                obj.epsilon = epsilon;
            end
            obj.state = create_cells(N(1:end-1,:),'zeros',is_gpu);
        end

        function gradient = optimize(obj,gradient)
            obj.state = cellfun(@(state,grad)state+grad.^2, obj.state,gradient,'UniformOutput',false);
            gradient = cellfun(@(state,grad)grad./sqrt(state+obj.epsilon), obj.state,gradient,'UniformOutput',false);
        end
    end
end