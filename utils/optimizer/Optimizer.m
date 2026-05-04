classdef (Abstract) Optimizer < handle
    methods (Abstract)
        optimize(gradient);
        reset();
        circshift(N);
    end
end