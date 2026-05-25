classdef GetMaskMax < GetMaskOutput
    properties (Access=protected)
        Maximum;
    end
    methods
        function obj = GetMaskMax(Mesh, prev, Mask)
            obj = obj@GetMaskOutput(Mesh, prev, Mask);
        end
        
        function score = get_output(obj, input)
            Field = get_output@GetMaskOutput(obj,input);
            score = max(Field,[],[1 2]);
            obj.Maximum = Field == score;
            score = permute(score, [4 3 2 1]);
        end
        function set_error_field(obj, error)
            error = permute(error, [4 3 2 1]);
            set_error_field@GetOutput(obj,sum(obj.Maximum.*error,4));
        end
    end
end

