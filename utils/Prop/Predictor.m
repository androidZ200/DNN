classdef (Abstract) Predictor < handle
    methods (Abstract)
        pred = get_prediction();
    end
end