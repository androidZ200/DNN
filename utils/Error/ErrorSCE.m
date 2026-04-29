classdef ErrorSCE < ErrorFunction
    properties
        alpha;
    end
    methods
        function obj = ErrorSCE(alpha)
            if nargin > 0
                obj.alpha = alpha;
            else
                obj.alpha = 1;
            end
        end

        function error = get_error(obj,out,target)
            p = exp(out*obj.alpha);
            error = -sum(target.*log(-p./sum(p,4)),4);
        end
        function gradient = get_gradient(obj,out,target)
            p = exp(obj.alpha*out);
            S = sum(p,4);
            p = p./S;
            gradient = -obj.alpha*(target - sum(target,4).*p);
        end
    end
end