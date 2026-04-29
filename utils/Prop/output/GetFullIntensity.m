classdef GetFullIntensity < GetOutput
    properties
        Mask;
    end

    methods
        function obj = GetFullIntensity(pixel,N,is_gpu,Mask)
            obj = obj@GetOutput(pixel,N,is_gpu);
            if(nargin > 3)
                obj.Mask = Mask;
            else
                obj.Mask = 1;
            end
        end

        function W_out = propagation(obj, W_in)
            W_out = propagation@GetOutput(obj,W_in).*obj.Mask;
        end
        function W_out = back_propagation(obj, W_in)
            W_out = back_propagation@GetOutput(obj,W_in).*obj.Mask;
        end
    end
end