classdef CompiledMatrixPropagator < Prop & MatrixPropagator
    properties(SetAccess=private)
        Mat_left_f = 1;
        Mat_right_f = 1;
        Mat_left_b = 1;
        Mat_right_b = 1;

        mesh_in = [];
        mesh_out = [];

        next_node = [];
        prev_node = [];
    end
    properties(Access=private)
        queue = [];
    end

    methods
        function obj = CompiledMatrixPropagator(prev, mesh)
            if nargin > 1
                mustBeA(mesh, "Mesh");
                obj.mesh_in = mesh;
                obj.mesh_out = mesh;

                obj.set_prev_node(prev);
            else
                obj.set_prev_node(prev);
                obj.mesh_in = obj.prev_node.output_mesh();
                obj.mesh_out = obj.mesh_in;
            end

            obj.Mat_left_f = GPUTest(eye(size(obj.mesh_in,1)));
            obj.Mat_right_f = GPUTest(eye(size(obj.mesh_in,2)));
            obj.Mat_left_b = obj.Mat_left_f;
            obj.Mat_right_b = obj.Mat_right_f;
        end
        
        function obj = add_next(obj, node)
            mustBeA(node, "Prop");
            mustBeA(node, "MatrixPropagator");
            if ~isequal(node, obj.next_node)
                error("Node must be a next node");
            end
            obj.queue = node;
            obj.next_node = [];
        end
        function field = get_field(obj, input)
            field = obj.prev_node.get_field(input);
            field = Field(obj.mesh_out, pagemtimes(obj.Mat_left_f, pagemtimes(field.CA, obj.Mat_right_f)));
        end
        function set_error_field(obj, error)
            error = Field(obj.mesh_in, pagemtimes(obj.Mat_left_b, pagemtimes(error.CA, obj.Mat_right_b)));
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
        function set_next_node(obj, node)
            if isequal(obj.next_node, node); return; end
            mustBeA(node,"Opt_Input");
            obj.next_node = node;
            obj.pop();
            node.set_prev_node(obj);
        end
        function set_prev_node(obj, node)
            if isequal(obj.prev_node, node); return; end
            mustBeA(node,"Encoder");
            obj.prev_node = node;
            node.set_next_node(obj);
        end
        function clear(obj)
            obj.prev_node.clear();
        end
        function M = get_left_f(obj)
            M = obj.Mat_left_f;
        end
        function M = get_right_f(obj)
            M = obj.Mat_right_f;
        end
        function M = get_left_b(obj)
            M = obj.Mat_left_b;
        end
        function M = get_right_b(obj)
            M = obj.Mat_right_b;
        end
    end

    methods (Access=private)
        function pop(obj)
            if ~isempty(obj.queue)
                obj.queue.set_next_node(obj.next_node);
                node = obj.queue;
                obj.queue = [];
                obj.mesh_out = node.output_mesh();
    
                obj.Mat_left_f = node.get_left_f()*obj.Mat_left_f;
                obj.Mat_right_f = obj.Mat_right_f*node.get_right_f();
                obj.Mat_left_b = obj.Mat_left_b*node.get_left_b();
                obj.Mat_right_b = node.get_right_b()*obj.Mat_right_b;
            end
        end
    end
end

