classdef ErrorSUM < ErrorFunction
    properties (SetAccess=private)
        errors = {};
        weights = [];
    end
    
    methods
        function obj = ErrorSUM(error, weight)
            obj.add_new(error, weight);
        end
        
        function obj = add_new(obj, error, weight)
            mustBeA(error, "ErrorFunction");
            obj.errors{end+1} = error;
            if nargin > 2 && ~isempty(weight)
                mustBeScalarOrEmpty(weight);
                obj.weights(end+1) = weight;
            else
                obj.weights(end+1) = 1;
            end
        end
        function error = get_error(obj, input, index)
            error = 0;
            for iter=1:length(obj.errors)
                error = error + obj.errors{iter}.get_error(input, index).*obj.weights(iter);
            end
        end
        function minimize(obj, speed, weight)
            if nargin < 3
                weight = 1;
            end
            for iter=1:length(obj.errors)
                obj.errors{iter}.minimize(speed, weight*obj.weights(iter));
            end
        end
    end
end

