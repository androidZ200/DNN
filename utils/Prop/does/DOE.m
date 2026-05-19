classdef (Abstract) DOE < Prop
    methods (Abstract)
        circshift(N);
        imagesc();
        get_field();
        step(gradient, speed);
    end

    methods
        function obj = DOE(Mesh, optimizer_fabric, mask)
            if ~isa(Mesh, "Mesh")
                error("Mesh must be Mesh object");
            end
            obj.Mesh = Mesh;

            if nargin < 2 || isempty(optimizer_fabric)
                obj.optimizer = [];
                obj.Train_Mask = 0;
            else
                if ~isa(optimizer_fabric, "OptimizerFabric")
                    error('optimizer_fabric must be OptimizerFabric class');
                end

                obj.optimizer = optimizer_fabric.generate(Mesh);
                if nargin < 3
                    obj.Train_Mask = 1;
                else
                    obj.Train_Mask = GPUTest(mask);
                end
            end

        end

        function W = propagation(obj,W)
            if obj.is_trainable()
                obj.Input_field = W;
            end
            W = W.*obj.get_field();
        end
        function W = back_propagation(obj,W)
            W = W.*obj.get_field();
            if obj.is_trainable()
                obj.Error_field = W;
            end
        end
        function mesh = input_mesh(obj)
            mesh = obj.Mesh;
        end
        function mesh = output_mesh(obj)
            mesh = obj.Mesh;
        end
        function init(obj, Before_Mesh, After_Mesh)
        end

        function is = is_trainable(obj)
            is = max(obj.Train_Mask,[],'all') > 0;
        end
        function obj = set_mask(obj, Mask)
            obj.Train_Mask = GPUTest(Mask);
        end
        function sz = size(obj, N)
            if nargin > 1
                sz = size(obj.Mesh, N);
            else
                sz = size(obj.Mesh);
            end
        end
    end

    methods (Access=protected)
        function error = get_error(obj)
            if obj.is_trainable()
                error = obj.Input_field.*obj.Error_field;
            else
                error = 0;
            end
        end
        function gradient = preparing_gradient(obj, gradient, speed)
            gradient = sum(gradient,setdiff(find(size(gradient)),[1 2]));
            gradient = obj.optimizer.optimize(gradient);
            gradient = -speed*gradient.*obj.Train_Mask;
        end
    end


    properties (SetAccess=protected)
        Mesh Mesh;
        Train_Mask;
    end
    properties (Access=protected)
        Input_field;
        Error_field;
        optimizer;
    end
end