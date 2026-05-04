classdef (Abstract) DOE < Prop & handle
    methods (Abstract)
        circshift(N);
        imagesc();
        get_field();
        step(gradient, speed);
    end
    methods
        function obj = DOE(Mesh,optimizer_fabric)
            if ~isa(Mesh, "Mesh")
                error("Mesh must be Mesh object");
            end
            obj.Mesh = Mesh;

            if nargin < 2 || isempty(optimizer_fabric)
                obj.optimizer = [];
                obj.Train_Mask = 0;
            else
                obj.optimizer = optimizer_fabric.generate(Mesh);
                obj.Train_Mask = 1;
            end

        end
        function W = propagation(obj,W)
            if obj.is_trainable()
                obj.Input_field = W;
            end
            W = W.*obj.get_field();
        end
        function W = back_propagation(obj,W)
            W = obj.propagation(W);
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

        function is = is_trainable(obj)
            is = max(obj.Train_Mask,[],'all') > 0;
        end
        function obj = set_mask(obj, Mask)
            obj.Train_Mask = GPUTest(Mask);
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
    end


    properties (SetAccess=protected)
        Mesh Mesh;
        Train_Mask logical;
    end
    properties (Access=protected)
        Input_field;
        Error_field;
        optimizer Optimizer;
    end
end