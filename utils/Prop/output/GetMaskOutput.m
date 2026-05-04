classdef (Abstract) GetMaskOutput < GetOutput
    properties (SetAccess=protected)
        Mask
    end
    
    methods
        function obj = GetMaskOutput(Mesh,Mask)
            obj = obj@GetOutput(Mesh);
            obj.Mask = reshpe(Mask, size(Mask,1), size(Mask,2), 1, []);
        end
        
        function W_out = propagation(obj, W_in)
            W_out = propagation@GetOutput(obj,W_in).*obj.Mask;
        end
    end
end

