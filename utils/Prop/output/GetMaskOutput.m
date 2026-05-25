classdef (Abstract) GetMaskOutput < GetOutput
    properties (SetAccess=protected)
        Mask;
    end
    
    methods
        function obj = GetMaskOutput(Mesh, prev, Mask)
            obj = obj@GetOutput(Mesh, prev);
            obj.Mask = reshape(Mask, size(Mask,1), size(Mask,2), 1, []);
        end
        
        function score = get_output(obj, input)
            score = get_output@GetOutput(obj,input).*obj.Mask;
        end
        function count = count_outputs(obj) 
            count = size(obj.Mask, 4);
        end
    end
end

