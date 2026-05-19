classdef ErrorMSE < ErrorFunction
    methods
        function error = get_error(obj,out,target)
            error = sum((out - target).^2);
        end
        function gradient = get_gradient(obj,out,target)
            gradient = 2*(out - target);
        end
    end
end

