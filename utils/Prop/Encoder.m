classdef (Abstract) Encoder < Back_Propogator
    methods (Abstract)
        field = get_field(input);
        mesh = output_mesh();
        set_output_mesh(mesh);
    end
end

