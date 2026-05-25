classdef ErrorMAENorm < Error_Decoder
    methods
        function obj = ErrorMAENorm(decoder)
            obj = obj@Error_Decoder(decoder);
        end
        function error = error(~,out,target)
            I = sum(out);
            error = sum(abs(out./I - target));
        end
        function gradient = gradient(~,out,target)
            I = sum(out);
            out = out./I;
            p = out - target;
            p = p./abs(p);
            p(isnan(p)) = 0;
            gradient = 2*(p-sum(out.*p))./I;
        end
    end
end
