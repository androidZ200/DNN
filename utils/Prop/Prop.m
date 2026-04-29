classdef (Abstract) Prop
    methods (Abstract)
       W_out = propagation(W_in);
       W_out = back_propagation(W_in);

       mesh = input_mesh();
       mesh = output_mesh();
    end
end