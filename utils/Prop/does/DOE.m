classdef (Abstract) DOE < Prop
    properties (SetAccess=protected)
        mesh Mesh;
        prev_node;
        type;
    end
    properties (Access=protected)
        Input_field;
        Gradient;
        TF; % transmission function
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
            mustBeA(prev, "Encoder");
            obj.prev_node = prev;
            mustBeA(type, "TypeDOE");
            obj.type = type;
            obj.prev_node.set_output_mesh(obj.mesh);
        end

        function W = get_field(obj, input)
            field = obj.prev_node.get_field(input);
            if obj.is_trainable(); obj.Input_field = field; end
            if isempty(obj.TF); obj.TF = obj.get_transmission_function(); end
            W = field.*obj.TF;
        end

        function need = need_error_field(obj)
            need = obj.is_trainable() || obj.prev_node.need_error_field();
        end

        function set_error_field(obj, error)
            error = error.*obj.TF;
            if obj.is_trainable()
                grad = obj.get_gradient(error.*obj.Input_field);
                sumdim = setdiff(find(size(grad) > 1), [1 2]);
                if ~isempty(sumdim); grad = sum(grad,sumdim); end
                if isempty(obj.Gradient)
                    obj.Gradient = grad;
                else
                    obj.Gradient = obj.Gradient + grad;
                end
            end
            if obj.prev_node.need_error_field()
                obj.prev_node.set_error_field(error);
            end
        end

        function mesh = input_mesh(obj)
            mesh = obj.mesh;
        end

        function mesh = output_mesh(obj)
            mesh = obj.input_mesh();
        end

        function set_output_mesh(obj, mesh)
            mustBeA(mesh, "Mesh");
            if ~isequal(obj.mesh, mesh)
                error('The Meshes dont match');
            end
        end

        function clear(obj)
            obj.Input_field = [];
            obj.Gradient = [];
            obj.TF = [];
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