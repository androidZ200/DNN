classdef Predictor < Decoder
    properties (SetAccess=private)
        decoder;
    end
    properties (Access=private)
        last_score;
    end

    methods
        function obj = Predictor(decoder)
            mustBeA(decoder,"Decoder");
            obj.decoder = decoder;
        end

        function pred = get_prediction(obj)
            [~, pred] = max(obj.last_score,[],1);
        end

        function score = get_output(obj, input)
            obj.last_score = obj.decoder.get_output(input);
            score = obj.last_score;
        end
        function count = count_outputs(obj)
            count = obj.decoder.count_outputs();
        end
        function need = need_error_field(obj)
            need = obj.decoder.need_error_field();
        end
        function set_error_field(obj, error)
            obj.decoder.set_error_field(error);
        end
        function gradient_step(obj, speed)
            obj.decoder.gradient_step(speed);
        end
        function clear(obj)
            obj.last_score = [];
            obj.decoder.clear();
        end
    end
end