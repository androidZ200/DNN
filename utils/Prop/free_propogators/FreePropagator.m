classdef (Abstract) FreePropagator < Prop
    properties
        distance;
        wavelength;
        prev_node;
    end

    methods (Abstract)
        init(out_mesh);
    end

    methods
        function obj = FreePropagator(prev)
            mustBeA(prev,"Encoder");
            obj.prev_node = prev;
        end
        function need = need_error_field(obj)
            need = obj.prev_node.need_error_field();
        end
        function gradient_step(obj, speed)
            obj.prev_node.gradient_step(speed);
        end
        function set_output_mesh(obj, mesh)
            mustBeA(mesh,"Mesh");
            obj.init(mesh);
        end
        function clear(obj)
            obj.prev_node.clear();
        end
    end
end