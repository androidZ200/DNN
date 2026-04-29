classdef (Abstract) GetMaskOutput < GetOutput
    properties
        Mask
    end
    
    methods
        function obj = GetMaskOutput(pixel,N,is_gpu,Mask)
            obj = obj@GetOutput(pixel,N,is_gpu);
            obj.Mask = reshpe(Mask, size(Mask,1), size(Mask,2), 1, []);
        end
        
        function W_out = propagation(obj, W_in)
            W_out = propagation@GetOutput(obj,W_in).*obj.Mask;
        end
    end
end

