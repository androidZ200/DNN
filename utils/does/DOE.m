classdef (Abstract) DOE < handle
    methods (Abstract)
        get_gradient(error)
        gradient_step(gradient)
        circshift(N)
        get_field()
    end
    methods
        function W = propagation(obj,W)
            W = W.*obj.get_field();
        end
        function C = times(A,B)
            if isa(A, 'DOE')
                C = propagation(A,B);
            else
                C = propagation(B,A);
            end
        end
    end
end