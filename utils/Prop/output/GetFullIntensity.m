classdef GetFullIntensity < GetOutput
    properties (SetAccess=protected)
        Mask logical;
    end

    methods
        function obj = GetFullIntensity(Mesh,Mask)
            obj = obj@GetOutput(Mesh);
            if(nargin > 1)
                obj.Mask = GPUTest(Mask);
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