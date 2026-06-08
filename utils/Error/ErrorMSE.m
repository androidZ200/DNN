classdef ErrorMSE < Error_Decoder
    methods
        function obj = ErrorMSE(decoder, target)
            obj = obj@Error_Decoder(decoder, target);
        end
        function error = error(~,out,target)
            error = sum((out - target).^2);
        end
        function gradient = gradient(~,out,target)
            gradient = 2*(out - target);
        end
    end
end

