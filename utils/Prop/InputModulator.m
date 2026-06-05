classdef InputModulator < Encoder
    properties (SetAccess=private)
        Mesh Mesh;
        Func;
        next_node;
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
            field = Field(obj.Mesh, obj.Func(input));
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
        function set_next_node(obj, node)
            if isequal(obj.next_node, node); return; end
            mustBeA(node,"Opt_Input");
            obj.next_node = node;
            obj.next_node.set_prev_node(obj);
        end
        function clear(~)
        end
    end
end