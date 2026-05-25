classdef (Abstract) Error_Decoder < ErrorFunction
    properties (SetAccess=protected)
        decoder;
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
        function obj = Error_Decoder(decoder)
            mustBeA(decoder,"Decoder");
            obj.decoder = decoder;
        end
        
        function error = get_error(obj, input, target)
            obj.last_target = target;
            obj.last_scores = obj.decoder.get_output(input);
            error = obj.error(obj.last_scores, obj.last_target);
        end
        function minimize(obj, speed)
            if obj.decoder.need_error_field()
                gradient = obj.gradient(obj.last_scores, obj.last_target);
                obj.decoder.set_error_field(gradient);
                obj.decoder.gradient_step(speed);
            end
            obj.decoder.clear();
        end
    end
end

