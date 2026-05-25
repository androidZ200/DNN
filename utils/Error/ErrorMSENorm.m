classdef ErrorMSENorm < Error_Decoder
    methods
        function obj = ErrorMSENorm(decoder)
            obj = obj@Error_Decoder(decoder);
        end
        function error = error(~,out,target)
            I = sum(out);
            error = sum((out./I - target).^2);
        end
        function gradient = gradient(~,out,target)
                I = sum(out);
                out = out./I;
                p = out - target;
                gradient = 2*(p-sum(out.*p))./I;
        end
    end
end

