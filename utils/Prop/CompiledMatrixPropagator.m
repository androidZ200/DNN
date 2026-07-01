classdef CompiledMatrixPropagator < Prop & MatrixPropagator
    properties(SetAccess=private)
        Mat_left = 1;
        Mat_right = 1;

        mesh_in = [];
        mesh_out = [];

        prev_node = [];
    end
    properties(Access=private)
        queue = {};
        deep_count = 0;
    end

    methods
        function obj = CompiledMatrixPropagator(prev)
            mustBeA(prev,"Encoder");
            obj.prev_node = prev;
            obj.mesh_in = prev.output_mesh();
            obj.mesh_out = obj.mesh_in;

            obj.Mat_left = GPUTest(eye(size(obj.mesh_in,1)));
            obj.Mat_right = GPUTest(eye(size(obj.mesh_in,2)));
        end
        
        function obj = add_next(obj, node)
            mustBeA(node, "Prop");
            mustBeA(node, "MatrixPropagator");
            
            obj.queue{end+1} = node;
            obj.mesh_out = node.output_mesh();
        end
        function field = get_field(obj, input)
            if ~isempty(obj.queue)
                error("The queue is not empty");
            end
            field = obj.prev_node.get_field(input);
            field = Field(obj.prop(obj.Mat_left, field.CA, obj.Mat_right));
        end
        function set_error_field(obj, error)
            error = Field(obj.prop(obj.Mat_left.', error.CA, obj.Mat_right.'));
            obj.prev_node.set_error_field(error);
        end
        function mesh = input_mesh(obj)
            mesh = obj.mesh_in;
        end
        function mesh = output_mesh(obj)
            mesh = obj.mesh_out;
        end
        function need = need_error_field(obj)
            need = obj.prev_node.need_error_field();
        end
        function gradient_step(obj, speed)
            obj.prev_node.gradient_step(speed);
        end
        function set_output_mesh(obj, mesh)
            mustBeA(mesh,"Mesh");
            obj.deep_count = obj.deep_count + 1;
            if length(obj.queue) >= obj.deep_count
                obj.queue{end - obj.deep_count + 1}.set_output_mesh(mesh);
                obj.pop();
            elseif isempty(obj.mesh_in)
                obj.prev_node.set_output_mesh(mesh);
                obj.mesh_in = mesh;
            end
            obj.deep_count = obj.deep_count - 1;
            if obj.deep_count == 0
                obj.mesh_out = mesh;
            end
        end
        function clear(obj)
            obj.prev_node.clear();
        end
        function M = get_left(obj)
            M = obj.Mat_left;
        end
        function M = get_right(obj)
            M = obj.Mat_right;
        end
    end

    methods (Access=private)
        function pop(obj)
            node = obj.queue{1};
            if length(obj.queue) > 1
                obj.queue = obj.queue(2:end);
            else
                obj.queue = {};
            end

            obj.Mat_left = node.get_left()*obj.Mat_left;
            obj.Mat_right = obj.Mat_right*node.get_right();
        end
    end
end

