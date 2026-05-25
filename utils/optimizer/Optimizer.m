classdef (Abstract) Optimizer < handle
    methods (Abstract)
        optimize(gradient);
        reset();
    end
end