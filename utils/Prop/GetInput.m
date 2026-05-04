classdef GetInput < handle
    properties (SetAccess=private)
        Mesh Mesh;
        Func = @(W)W;
    end

    methods
        function obj = GetInput(Mesh, Func)
            obj.Mesh = Mesh;
            if nargin > 1
                obj.Func = Func;
            end
        end

        function W_out = propagation(obj,Data)
            W_out = obj.Func(Data);
        end
        function mesh = output_mesh(obj)
            mesh = obj.Mesh;
        end
    end
end