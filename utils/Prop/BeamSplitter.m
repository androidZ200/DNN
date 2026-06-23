classdef BeamSplitter < Prop
    properties(SetAccess=private)
        prev_node;
        mesh Mesh;
    end
    properties(Access=private)
        field;
        error;
        counter = 0;
    end
    
    methods
        function obj = BeamSplitter(prev, mesh)
            mustBeA(prev, "Encoder");
            obj.prev_node = prev;
            if nargin > 1
                obj.mesh = mesh;
                obj.prev_node.set_output_mesh(mesh);
            else
                obj.mesh = prev.output_mesh();
            end
        end
        
        function mesh = input_mesh(obj)
            mesh = obj.mesh;
        end
        function mesh = output_mesh(obj)
            mesh = obj.mesh;
        end
        function set_output_mesh(obj, mesh)
            mustBeA(mesh, "Mesh");
            if isempty(obj.mesh)
                obj.mesh = mesh;
                obj.prev_node.set_output_mesh(mesh);
            elseif ~isequal(obj.mesh, mesh)
                error('The Meshes dont match');
            end
        end
        function field = get_field(obj, input)
            if isempty(obj.field)
                obj.field = obj.prev_node.get_field(input);
            end
            field = obj.field;
            obj.counter = obj.counter + 1;
        end
        function need = need_error_field(obj)
            need = obj.prev_node.need_error_field();
        end
        function set_error_field(obj, error)
            if isempty(obj.error)
                obj.error = error;
            else
                obj.error = obj.error + error;
            end
            obj.counter = obj.counter - 1;
            if obj.counter == 0
                obj.prev_node.set_error_field(obj.error);
            end
        end
        function gradient_step(obj, speed)
            if ~isempty(obj.error)
                obj.prev_node.gradient_step(speed);
                obj.error = [];
            end
        end
        function clear(obj)
            if ~isempty(obj.field)
                obj.error = [];
                obj.field = [];
                obj.counter = 0;
                obj.prev_node.clear();
            end
        end
    end
end

