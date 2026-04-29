classdef (Abstract) DOE < Mesh & Prop & Trainable
    methods (Abstract)
        circshift(N)
        imagesc()
        get_field()
    end
    methods
        function obj = DOE(pixel,N,is_gpu,optimizer_fabric)
            if nargin <= 3
                optimizer_fabric = SGDFabric();
            end
            obj = obj@Mesh(pixel,N,is_gpu);
            obj = obj@Trainable(N,is_gpu,optimizer_fabric);
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
            mesh = obj;
        end
        function mesh = output_mesh(obj)
            mesh = obj;
        end
    end
    methods (Access=protected)
        function error = get_error(obj)
            error = obj.Input_field.*obj.Error_field;
        end
    end
    properties (Access=private)
        Input_field;
        Error_field;
    end
end