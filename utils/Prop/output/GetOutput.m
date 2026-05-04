classdef (Abstract) GetOutput < handle
    properties (SetAccess=protected)
        Mesh Mesh;
    end
    properties (Access=protected)
        lastW;
    end

    methods
        function obj = GetOutput(Mesh)
            obj.Mesh = Mesh;
        end

        function W_out = propagation(obj, W_in)
            obj.lastW = W_in;
            W_out = abs(W_in).^2;
        end
        function W_out = back_propagation(obj, W_in)
            W_out = 2*W_in.*conj(obj.lastW);
        end
        function mesh = input_mesh(obj)
            mesh = obj.Mesh;
        end
    end
end