classdef GetMaskSum < GetMaskOutput
    methods
        function obj = GetMaskSum(prev, Mesh, Mask)
            obj = obj@GetMaskOutput(prev, Mesh, Mask);
        end
        
        function score = get_output(obj, input)
            score = sum(get_output@GetMaskOutput(obj,input),[1 2]);
            score = permute(score, [4 3 2 1]);
            obj.lastScore = score;
        end
        function set_error_field(obj, error)
            error = permute(error, [4 3 2 1]);
            set_error_field@GetOutput(obj,sum(obj.Mask.*error,4));
        end
    end
end

