classdef (Abstract) Prop
    methods (Abstract)
        init(Before_Mesh, After_Mesh);

        W_out = propagation(W_in);
        W_out = back_propagation(W_in);

        mesh = input_mesh();
        mesh = output_mesh();

        gradient = get_gradient();
        step(gradient, speed);
    end
end