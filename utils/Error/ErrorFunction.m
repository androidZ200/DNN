classdef (Abstract) ErrorFunction < handle
    methods (Abstract)
        error = get_error(input, target);
        minimize(speed);
    end
end

