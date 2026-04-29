classdef ErrorMSENorm < ErrorFunction
    methods
        function error = get_error(obj,out,target)
            I = sum(out,4);
            error = sum((out./I - target).^2, 4);
        end
        function gradient = get_gradient(obj,out,target)
                I = sum(out,4);
                out = out./I;
                p = out - target;
                gradient = 2*(p-sum(out.*p,4))./I;
        end
    end
end

