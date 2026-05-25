classdef (Abstract) GetOutput < Decoder & Opt_Input
    properties (SetAccess=protected)
        Mesh Mesh;
        prev_node;
    end
    properties (Access=protected)
        lastW;
    end

    methods
        function obj = GetOutput(Mesh, prev)
            obj.Mesh = Mesh;
            obj.set_prev_node(prev);
        end

        function set_prev_node(obj, node)
            if isequal(obj.prev_node, node); return; end
            mustBeA(node,"Encoder");
            obj.prev_node = node;
            obj.prev_node.set_next_node(obj);
        end
        function need = need_error_field(obj)
            need = obj.prev_node.need_error_field();
        end
        function gradient_step(obj, speed)
            obj.prev_node.gradient_step(speed);
        end
        function clear(obj)
            obj.lastW = [];
            obj.prev_node.clear();
        end
        function score = get_output(obj, input)
            if isempty(obj.lastW)
                field = obj.prev_node.get_field(input);
                obj.lastW = field;
            end
            score = intensity(obj.lastW);
        end
        function set_error_field(obj, error)
            error = Field(obj.Mesh, 2*error.*conj(obj.lastW.CA));
            obj.prev_node.set_error_field(error);
        end
        function mesh = input_mesh(obj)
            mesh = obj.Mesh;
        end
    end
end