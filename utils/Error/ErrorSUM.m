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
            if obj.need_error_field()
                if nargin < 3
                    weight = 1;
                end
                obj.set_error_field(weight);
                obj.gradient_step(speed);
            end
            obj.clear();
        end
        function need = need_error_field(obj)
            need = false;
            for iter=1:length(obj.errors)
                need = need || obj.errors{iter}.need_error_field();
            end
        end
        function set_error_field(obj, error)
            for iter=1:length(obj.errors)
                obj.errors{iter}.set_error_field(error*obj.weights(iter));
            end
        end
        function gradient_step(obj, speed)
            for iter=1:length(obj.errors)
                obj.errors{iter}.gradient_step(speed);
            end
        end
        function clear(obj)
            for iter=1:length(obj.errors)
                obj.errors{iter}.clear();
            end
        end
    end
end

