classdef ErrorMSENorm < ErrorFunction
    methods
        function error = get_error(~,out,target)
            I = sum(out);
            error = sum((out./I - target).^2);
        end
        function gradient = get_gradient(~,out,target)
                I = sum(out);
                out = out./I;
                p = out - target;
                gradient = 2*(p-sum(out.*p))./I;
        end
    end
end

