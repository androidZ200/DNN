classdef ScoreSpliter < Decoder & Predictor
    properties (Access=private)
        input;
        error;
        count = 0;
    end
    properties (SetAccess=protected)
        decoder
    end

    methods
        function obj = ScoreSpliter(decoder)
            mustBeA(decoder,"Decoder");
            obj.decoder = decoder;
        end

        function pred = get_prediction(obj)
            [~,pred] = max(obj.input,[],1);
        end
        function score = get_output(obj, input)
            if isempty(obj.input)
                obj.input = obj.decoder.get_output(input);
            end
            score = obj.input;
            obj.count = obj.count + 1;
        end
        function count = count_outputs(obj)
            count = obj.decoder.count_outputs();
        end
        function need = need_error_field(obj)
            need = obj.decoder.need_error_field();
        end
        function set_error_field(obj, error)
            if isempty(obj.error)
                obj.error = error;
            else
                obj.error = obj.error + error;
            end
            obj.count = obj.count - 1;
            if obj.count == 0
                obj.decoder.set_error_field(obj.error);
            end
        end
        function gradient_step(obj, speed)
            if ~isempty(obj.error)
                obj.decoder.gradient_step(speed);
                obj.error = [];
            end
        end
        function clear(obj)
            if ~isempty(obj.input)
                obj.input = [];
                obj.error = [];
                obj.decoder.clear();
            end
        end
    end
end

