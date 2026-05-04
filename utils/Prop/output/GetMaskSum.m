classdef GetMaskSum < GetMaskOutput
    methods
        function obj = GetMaskSum(Mesh,Mask)
            obj = obj@GetMaskOutput(Mesh,Mask);
        end
        
        function W_out = propagation(obj, W_in)
            W_out = sum(propagation@GetMaskOutput(obj,W_in),[1 2]);
        end
        function W_out = back_propagation(obj, W_in)
            W_out = back_propagation@GetOutput(obj,sum(obj.Mask.*W_in,4));
        end
    end
end

