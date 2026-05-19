classdef GetMaskMax < GetMaskOutput
    properties (Access=protected)
        Maximum;
    end
    methods
        function obj = GetMaskMax(Mesh,Mask)
            obj = obj@GetMaskOutput(Mesh,Mask);
        end
        
        function W_out = propagation(obj, W_in)
            Field = propagation@GetMaskOutput(obj,W_in);
            W_out = max(Field,[],[1 2]);
            obj.Maximum = Field == W_out;
            W_out = permute(W_out, [4 3 2 1]);
        end
        function W_out = back_propagation(obj, W_in)
            W_in = permute(W_in, [4 3 2 1]);
            W_out = back_propagation@GetOutput(obj,sum(obj.Maximum.*W_in,4));
        end
    end
end

