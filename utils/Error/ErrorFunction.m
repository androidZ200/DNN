classdef (Abstract) ErrorFunction < handle
    methods (Abstract)
        error = get_error(input, index);
        minimize(speed, weight);
    end
end

