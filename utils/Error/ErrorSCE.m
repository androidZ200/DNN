classdef ErrorSCE < Error_Decoder
    properties
        alpha;
    end
    methods
        function obj = ErrorSCE(decoder, target, alpha)
            obj = obj@Error_Decoder(decoder, target);
            if nargin > 1
                obj.alpha = alpha;
            else
                obj.alpha = 1;
            end
        end

        function error = error(obj,out,target)
            p = exp(out*obj.alpha);
            error = -sum(target.*log(p./sum(p)));
        end
        function gradient = gradient(obj,out,target)
            p = exp(obj.alpha*out);
            p = p./sum(p);
            gradient = -obj.alpha*(target - sum(target).*p);
        end
    end
end