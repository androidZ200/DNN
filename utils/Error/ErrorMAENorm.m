classdef ErrorMAENorm < ErrorFunction
    methods
        function error = get_error(obj,out,target)
            I = sum(out,4);
            error = sum(abs(out./I - target), 4);
        end
        function gradient = get_gradient(obj,out,target)
            I = sum(out,4);
            out = out./I;
            p = out - target;
            p = p./abs(p);
            p(isnan(p)) = 0;
            gradient = 2*(p-sum(out.*p,4))./I;
        end
    end
end
