classdef (Abstract) TypeDOE
    methods (Abstract)
        get_transmission_function(data);
        get_gradient(error, data);
        imagesc(X, Y, data);
    end
end

