classdef NormalizationMAX < Decoder & Predictor
    properties (Access=private)
        input;
    end
    properties (SetAccess=protected)
        decoder
    end

    methods
        function obj = NormalizationMAX(decoder)
            mustBeA(decoder,"Decoder");
            obj.decoder = decoder;
        end

        function pred = get_prediction(obj)
            [~,pred] = max(obj.input,[],1);
        end
        function score = get_output(obj, input)
            obj.input = obj.decoder.get_output(input);
            score = obj.input./max(obj.input);
        end
        function count = count_outputs(obj)
            count = obj.decoder.count_outputs();
        end
        function need = need_error_field(obj)
            need = obj.decoder.need_error_field();
        end
        function set_error_field(obj, error)
            S = permute(max(obj.input), [1 3 2]);
            M = (eye(size(obj.input,1)).*S - permute(obj.input, [3 1 2]).*(permute(obj.input, [1 3 2]) == S))./(S.^2);
            obj.decoder.set_error_field(permute(pagemtimes(M, permute(error, [1 3 2])), [1 3 2]));
        end
        function gradient_step(obj, speed)
            obj.decoder.gradient_step(speed);
        end
        function clear(obj)
            obj.input = [];
            obj.decoder.clear();
        end
    end
end
