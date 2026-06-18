classdef ErrorPEF < Error_Decoder % power efficiency function
    properties (SetAccess=private)
        InputEnergy = 1;
    end
    
    methods
        function obj = ErrorPEF(decoder, InputEnergy)
            obj@Error_Decoder(decoder, GenerationTarget(0));
            if nargin > 1
                obj.InputEnergy = InputEnergy;
            end
        end
        
        function error = error(obj,out,~)
            error = -log(sum(out)./obj.InputEnergy);
        end
        function gradient = gradient(obj,out,~)
            gradient = -2*obj.InputEnergy./sum(out);
        end
    end
end

% Joint loss function design in diffractive optical neural network classifiers for high power efficiency
% / F. Mengguang, J. Shuping, G. Yinwei, et al // Optics Express. - 2025. - Vol. 33, Issue 4. 
% - P. 7307-7320. - DOI: https://doi.org/10.1364/OE.547572