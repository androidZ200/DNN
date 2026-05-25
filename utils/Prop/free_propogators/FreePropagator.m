classdef (Abstract) FreePropagator < Prop
    properties
        distance;
        wavelength;
        next_node;
        prev_node;
    end

    methods (Abstract)
        init();
    end

    methods
        function obj = FreePropagator(prev)
            obj.set_prev_node(prev);
        end
        function need = need_error_field(obj)
            need = obj.prev_node.need_error_field();
        end
        function gradient_step(obj, speed)
            obj.prev_node.gradient_step(speed);
        end
        function set_next_node(obj, node)
            if isequal(obj.next_node, node); return; end
            mustBeA(node,"Opt_Input");
            obj.next_node = node;
            obj.init();
            node.set_prev_node(obj);
        end
        function set_prev_node(obj, node)
            if isequal(obj.prev_node, node); return; end
            mustBeA(node,"Encoder");
            obj.prev_node = node;
            obj.init();
            node.set_next_node(obj);
        end
        function clear(obj)
            obj.prev_node.clear();
        end
    end
end