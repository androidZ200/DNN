classdef NesterovOptimizer < Optimizer
    properties (Access = private)
        viscosity = 0.9;
        state;
    end

    methods
        function obj = NesterovOptimizer(Mesh, viscosity)
            if nargin > 1
                obj.viscosity = viscosity;
            end
            obj.state = GPUTest(zeros(size(Mesh), 'single'));
        end

        function gradient = optimize(obj,gradient)
            obj.state = obj.viscosity*obj.state + (1 - obj.viscosity)*gradient;
            gradient = obj.state;
        end
        function reset(obj)
            obj.state(:) = 0;
        end
    end
end