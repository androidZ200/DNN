classdef (Abstract) Optimizer < handle
    methods (Abstract)
        optimize(gradient)
    end
end