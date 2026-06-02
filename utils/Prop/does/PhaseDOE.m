classdef PhaseDOE < TypeDOE
    properties (Access = protected, Constant)
        ssau = [linspace_l(40,  32, 40), linspace_l( 32,  255, 40), linspace_l(255, 201, 40), linspace_l(201, 40, 40);...
                linspace_l(40, 146, 40), linspace_l(146,  255, 40), linspace_l(255,  88, 40), linspace_l( 88, 40, 40);...
                linspace_l(40, 201, 40), linspace_l(201,  255, 40), linspace_l(255,  32, 40), linspace_l( 32, 40, 40)]'/255;
    end

    methods
        function field = get_transmission_function(~, data)
            field = exp(1i*data);
        end
        function gradient = get_gradient(~, error, ~)
            gradient = -imag(error);
        end
        function im = imagesc(obj, X, Y, data)
            im = imagesc(X, Y, angle(obj.get_transmission_function(data)), [-pi pi]);
            colormap(obj.ssau);
        end
    end
end