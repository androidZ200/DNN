classdef (Abstract) Opt_Input < handle
    methods (Abstract)
        mesh = input_mesh();
    end
end