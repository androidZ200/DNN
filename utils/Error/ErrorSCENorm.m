classdef ErrorSCENorm < Error_Decoder
    properties
        alpha;
    end
    methods
        function obj = ErrorSCENorm(decoder, alpha)
            obj = obj@Error_Decoder(decoder);
            if nargin > 1
                obj.alpha = alpha;
            else
                obj.alpha = 1;
            end
        end

        function error = error(obj,out,target)
            I = sum(out);
            p = exp(out./I * obj.alpha);
            error = -sum(target.*log(p./sum(p)));
        end
        function gradient = gradient(obj,out,target)
            I = sum(out);
            out = out./I;
            p = exp(obj.alpha*out); 
            p = p./sum(p);
            p = (p-sum(p.*out)).*sum(target) + sum(target.*out) - target;
            gradient = p*obj.alpha*2./I;
        end
    end
end