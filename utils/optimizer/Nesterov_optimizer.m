classdef Nesterov_optimizer < Optimizer
    properties (Access = private)
        viscosity = 0.9;
        state;
    end

    methods
        function obj = Nesterov_optimizer(N, is_gpu, viscosity)
            if nargin > 2
                obj.viscosity = viscosity;
            end
            obj.state = create_cells(N(1:end-1,:),1,'zeros',is_gpu);
        end

        function gradient = optimize(obj,gradient)
            obj.state = cellfun(@(state,grad)obj.viscosity*state + (1 - obj.viscosity)*grad, ...
                obj.state,gradient,'UniformOutput',false);
            gradient = obj.state;
        end
    end
end