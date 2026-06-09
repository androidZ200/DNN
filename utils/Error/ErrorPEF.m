classdef ErrorPEF < ErrorFunction % power efficiency function
    properties (SetAccess=private)
        InputEnergy = 1;
        TargetEnergy;
        decoder;
    end
    
    methods
        function obj = ErrorPEF(decoder, InputEnergy)
            mustBeA(decoder,"Decoder");
            obj.decoder = decoder;
            if nargin > 1
                obj.InputEnergy = InputEnergy;
            end
        end
        
        function error = get_error(obj, input, ~)
            obj.TargetEnergy = sum(obj.decoder.get_output(input));
            error = -log(obj.TargetEnergy./obj.InputEnergy);
        end
        function minimize(obj, speed, weight)
            if obj.decoder.need_error_field()
                gradient = -2*obj.InputEnergy./obj.TargetEnergy;
                if nargin < 3
                    weight = 1;
                end
                obj.decoder.set_error_field(gradient*weight);
                obj.decoder.gradient_step(speed);
            end
            obj.decoder.clear();
        end
    end
end

% Joint loss function design in diffractive optical neural network classifiers for high power efficiency
% / F. Mengguang, J. Shuping, G. Yinwei, et al // Optics Express. - 2025. - Vol. 33, Issue 4. 
% - P. 7307-7320. - DOI: https://doi.org/10.1364/OE.547572