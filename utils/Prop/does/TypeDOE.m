classdef (Abstract) TypeDOE
    methods (Abstract)
        field = get_transmission_function(data);
        gradient = get_gradient(error, data);
        data = get_data_from(inp_data);
        imagesc(X, Y, data);
    end
end

