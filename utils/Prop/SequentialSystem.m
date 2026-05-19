classdef SequentialSystem < Prop
    properties (SetAccess=protected)
        Layers (1,:) = [];
    end
    
    methods
        function obj = SequentialSystem(Layers)
            if nargin < 1 || isempty(Layers)
                error("Layers can not be empty");
            end
            obj.Layers = Layers;
        end
        
        function init(obj, Before_Mesh, After_Mesh)
            if length(obj.Layers) == 1
                obj.Layers.init(Before_Mesh, After_Mesh);
            end
            obj.Layers{1}.init(Before_Mesh, obj.Layers{2});
            obj.Layers{end}.init(obj.Layers{end-1}, After_Mesh);
            for iter=2:length(obj.Layers)-1
                obj.Layers{iter}.init(obj.Layers{iter-1}, obj.Layers{iter+1});
            end
        end
        function W = propagation(obj, W)
            for iter=1:length(obj.Layers)
                W = obj.Layers{iter}.propagation(W);
            end
        end
        function W = back_propagation(obj, W)
            for iter=length(obj.Layers):-1:1
                W = obj.Layers{iter}.back_propagation(W);
            end
        end
        function mesh = input_mesh(obj)
            mesh = obj.Layers{1}.input_mesh();
        end
        function mesh = output_mesh(obj)
            mesh = obj.Layers{end}.output_mesh();
        end
        function gradient = get_gradient(obj)
            gradient = cell(1,length(obj.Layers));
            for iter=1:length(obj.Layers)
                gradient{iter} = obj.Layers{iter}.get_gradient();
            end
        end
        function step(obj, gradient, speed)
            for iter=1:length(obj.Layers)
                obj.Layers{iter}.step(gradient{iter}, speed);
            end
        end
    end
end

