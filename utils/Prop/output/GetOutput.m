classdef (Abstract) GetOutput < Prop & Mesh
    properties
        lastW;
    end
    methods
        function obj = GetOutput(pixel,N,is_gpu)
            obj@Mesh(pixel,N,is_gpu);
        end

        function W_out = propagation(obj, W_in)
            obj.lastW = W_in;
            W_out = abs(W_in).^2;
        end
        function W_out = back_propagation(obj, W_in)
            W_out = 2*W_in.*conj(obj.lastW);
        end
        function mesh = output_mesh(obj)
            mesh = obj;
        end
    end
end