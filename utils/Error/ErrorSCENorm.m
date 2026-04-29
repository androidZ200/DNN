classdef ErrorSCENorm < ErrorFunction
    properties
        alpha;
    end
    methods
        function obj = ErrorSCENorm(alpha)
            if nargin > 0
                obj.alpha = alpha;
            else
                obj.alpha = 1;
            end
        end

        function error = get_error(obj,out,target)
            I = sum(out,4);
            p = exp(out./I*obj.alpha);
            error = -sum(target.*log(-p./sum(p,4)),4);
        end
        function gradient = get_gradient(obj,out,target)
            I = sum(out,4);
            out = out./I;
            p = exp(obj.alpha*out); 
            p = p./sum(p);
            p = (p-sum(p.*out,4)).*sum(target,4) + sum(target.*out,4) - target;
            gradient = p*obj.alpha*2./I;
        end
    end
end