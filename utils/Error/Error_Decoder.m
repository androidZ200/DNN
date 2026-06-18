classdef (Abstract) Error_Decoder < ErrorFunction & Predictor
    properties (SetAccess=protected)
        decoder;
        target;
    end
    properties (Access=protected)
        last_scores;
        last_target;
    end

    methods (Abstract)
        error = error(scores, target);
        gradient = gradient(scores, target)
    end
    
    methods
        function obj = Error_Decoder(decoder, target)
            mustBeA(decoder,"Decoder");
            obj.decoder = decoder;
            mustBeA(target, "GetTarget");
            obj.target = target;
        end
        
        function pred = get_prediction(obj)
            [~,pred] = max(obj.last_scores,[],1);
        end
        function error = get_error(obj, input, index)
            obj.last_target = obj.target.get_target(index);
            obj.last_scores = obj.decoder.get_output(input);
            error = obj.error(obj.last_scores, obj.last_target);
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
            need = obj.decoder.need_error_field();
        end
        function set_error_field(obj, error)
            gradient = obj.gradient(obj.last_scores, obj.last_target);
            obj.decoder.set_error_field(gradient*error);
        end
        function gradient_step(obj, speed)
            obj.decoder.gradient_step(speed);
        end
        function clear(obj)
            obj.decoder.clear();
        end
    end
end

