classdef AmplitudeDOE < TypeDOE
    methods
        function field = get_transmission_function(obj, data)
            field = obj.sigmoid(data);
        end
        function gradient = get_gradient(obj, error, data)
            sig = obj.get_transmission_function(data);
            gradient = real(error).*sig.*(1 - sig);
        end
        function im = imagesc(obj, X, Y, data)
            im = imagesc(X, Y, obj.get_transmission_function(data), [0 1]);
            colormap(gray);
        end
    end

    methods (Access = private, Static)
        function y = sigmoid(x)
            y = 1./(1 + exp(-x));
        end
    end
end