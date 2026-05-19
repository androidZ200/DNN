classdef (Abstract) GetMaskOutput < GetOutput
    properties (SetAccess=protected)
        Mask;
    end
    
    methods
        function obj = GetMaskOutput(Mesh, Mask)
            obj = obj@GetOutput(Mesh);
            obj.Mask = reshape(Mask, size(Mask,1), size(Mask,2), 1, []);
        end
        
        function W_out = propagation(obj, W_in)
            W_out = propagation@GetOutput(obj,W_in).*obj.Mask;
        end
        function count = count_outputs(obj) 
            count = size(obj.Mask, 4);
        end
    end
end

