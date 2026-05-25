classdef (Abstract) Decoder < Back_Propogator
    methods (Abstract)
        score = get_output(input);
        count = count_outputs();
    end
end