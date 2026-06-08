classdef (Abstract) DOE < Prop
    properties (SetAccess=protected)
        mesh Mesh;
        next_node;
        prev_node;
        type;
    end
    properties (Access=protected)
        Input_field;
        Gradient;
    end
    
    methods (Abstract)
        get_transmission_function();
        is_trainable();
        get_gradient(error);
        make_gradient_step(gradient, speed);
    end

    methods
        function obj = DOE(prev, Mesh, type)
            obj.mesh = Mesh;
            obj.set_prev_node(prev);
            mustBeA(type, "TypeDOE");
            obj.type = type;
        end

        function W = get_field(obj, input)
            field = obj.prev_node.get_field(input);
            if obj.is_trainable()
                obj.Input_field = field;
            end
            W = Field(obj.mesh, field.CA.*obj.get_transmission_function());
        end

        function need = need_error_field(obj)
            need = obj.is_trainable() || obj.prev_node.need_error_field();
        end

        function set_error_field(obj, error)
            error = error.CA.*obj.get_transmission_function();
            if obj.is_trainable()
                grad = obj.get_gradient(error.*obj.Input_field.CA);
                sumdim = setdiff(find(size(grad) > 1), [1 2]);
                if ~isempty(sumdim)
                    grad = sum(grad,sumdim);
                end
                if isempty(obj.Gradient)
                    obj.Gradient = grad;
                else
                    obj.Gradient = obj.Gradient + grad;
                end
            end
            if obj.prev_node.need_error_field()
                obj.prev_node.set_error_field(Field(obj.mesh, error));
            end
        end

        function mesh = input_mesh(obj)
            mesh = obj.mesh;
        end

        function mesh = output_mesh(obj)
            mesh = obj.mesh;
        end
        
        function set_next_node(obj, node)
            if isequal(obj.next_node, node); return; end
            mustBeA(node,"Opt_Input");
            obj.next_node = node;
            node.set_prev_node(obj);
        end

        function set_prev_node(obj, node)
            if isequal(obj.prev_node, node); return; end
            mustBeA(node,"Encoder");
            obj.prev_node = node;
            node.set_next_node(obj);
        end

        function clear(obj)
            obj.Input_field = [];
            obj.Gradient = [];
            obj.prev_node.clear();
        end
        
        function sz = size(obj, N)
            if nargin > 1
                sz = size(obj.mesh, N);
            else
                sz = size(obj.mesh);
            end
        end

        function gradient_step(obj, speed)
            obj.make_gradient_step(obj.Gradient, speed);
            obj.prev_node.gradient_step(speed);
        end
    end
end