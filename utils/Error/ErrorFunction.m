classdef (Abstract) ErrorFunction
    methods (Abstract)
        error = get_error(out, target);
        gradient = get_gradient(out, target);
    end
end

