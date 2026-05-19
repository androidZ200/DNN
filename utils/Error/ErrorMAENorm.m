classdef ErrorMAENorm < ErrorFunction
    methods
        function error = get_error(obj,out,target)
            I = sum(out);
            error = sum(abs(out./I - target));
        end
        function gradient = get_gradient(obj,out,target)
            I = sum(out);
            out = out./I;
            p = out - target;
            p = p./abs(p);
            p(isnan(p)) = 0;
            gradient = 2*(p-sum(out.*p))./I;
        end
    end
end
