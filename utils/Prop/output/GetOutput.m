classdef (Abstract) GetOutput < Decoder & Opt_Input
    properties (SetAccess=protected)
        Mesh Mesh;
        prev_node;
    end
    properties (Access=protected)
        lastW;
    end

    methods
        function obj = GetOutput(prev, Mesh)
            obj.Mesh = Mesh;
            mustBeA(prev, "Encoder");
            obj.prev_node = prev;
            obj.prev_node.set_output_mesh(Mesh);
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
        function field = get_field(obj, input)
            if nargin > 1
                field = obj.prev_node.get_field(input);
                obj.lastW = field;
            elseif isempty(obj.lastW)
                error("not enourgt input arguments");
            end
            field = obj.lastW;
        end
        function int = intensity(obj, input)
            int = abs(obj.get_field(input)).^2;
        end
        function score = get_output(obj, input)
            score = obj.intensity(input);
        end
        function set_error_field(obj, error)
            error = 2*error.*conj(obj.lastW);
            obj.prev_node.set_error_field(error);
        end
        function mesh = input_mesh(obj)
            mesh = obj.Mesh;
        end
    end
end