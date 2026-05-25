classdef (Abstract) Encoder < Back_Propogator
    methods (Abstract)
        field = get_field(input);
        mesh = output_mesh();
        set_next_node(node);
    end
end

