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
            I = sum(out);
            p = exp(out./I * obj.alpha);
            error = -sum(target.*log(p./sum(p)));
        end
        function gradient = get_gradient(obj,out,target)
            I = sum(out);
            out = out./I;
            p = exp(obj.alpha*out); 
            p = p./sum(p);
            p = (p-sum(p.*out)).*sum(target) + sum(target.*out) - target;
            gradient = p*obj.alpha*2./I;
        end
    end
end