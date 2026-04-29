classdef GetInput < Prop & Mesh
    properties
        Func;
    end

    methods
        function obj = GetInput(Func,pixel,N,is_gpu)
            obj@Mesh(pixel,N,is_gpu);
            obj.Func = Func;
        end

        function W_out = propagation(obj,W_in)
            W_out = obj.Func(W_in);
        end
        function W_out = back_propagation(obj,W_in)
            error('can not prapogate filed before first plane');
            W_out = [];
        end
        function mesh = input_mesh(obj)
            error('input mesh not exist in first plane');
            mesh = [];
        end
        function mesh = output_mesh(obj)
            mesh = obj;
        end
    end
end