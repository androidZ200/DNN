classdef ErrorMAE < ErrorFunction
    methods
        function error = get_error(obj,out,target)
            error = sum(abs(out - target));
        end
        function gradient = get_gradient(obj,out,target)
            p = out - target;
            gradient = p./abs(p);
            gradient(isnan(gradient)) = 0;
        end
    end
end

