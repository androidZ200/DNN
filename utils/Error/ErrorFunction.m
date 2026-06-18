classdef (Abstract) ErrorFunction < Back_Propogator
    methods (Abstract)
        error = get_error(input, index);
        minimize(speed, weight);
    end
end

