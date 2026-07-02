classdef InputModulator < Encoder
    properties (SetAccess=private)
        Mesh Mesh;
        Func;
    end

    methods
        function obj = InputModulator(Mesh, Func)
            obj.Mesh = Mesh;
            if nargin > 1
                obj.Func = Func;
            else
                obj.Func = @(W)W;
            end
        end

        function field = get_field(obj, input)
            field = obj.Func(input);
        end
        function need = need_error_field(~)
            need = false;
        end
        function set_error_field(~, ~)
        end
        function gradient_step(~, ~)
        end
        function mesh = output_mesh(obj)
            mesh = obj.Mesh;
        end
        function set_output_mesh(obj, mesh)
            mustBeA(mesh, "Mesh");
            if ~isequal(obj.Mesh, mesh)
                error('The Meshes dont match');
            end
        end
        function clear(~)
        end
    end
end