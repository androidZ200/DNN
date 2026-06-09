classdef ErrorMAE < Error_Decoder % mean absolute error
    methods
        function obj = ErrorMAE(decoder, target)
            obj = obj@Error_Decoder(decoder, target);
        end
        function error = error(~,out,target)
            error = sum(abs(out - target));
        end
        function gradient = gradient(~,out,target)
            p = out - target;
            gradient = p./abs(p);
            gradient(isnan(gradient)) = 0;
        end
    end
end

