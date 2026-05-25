classdef (Abstract) Opt_Input < handle
    methods (Abstract)
        mesh = input_mesh();
        set_prev_node(node);
    end
end