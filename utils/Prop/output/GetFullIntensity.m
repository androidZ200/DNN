classdef GetFullIntensity < GetOutput
    properties (SetAccess=protected)
        Mask;
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
            W_out = reshape(W_out,[],size(W_in,3));
        end
        function W_out = back_propagation(obj, W_in)
            W_in = reshape(W_in,length(obj.Mesh.X),length(obj.Mesh.Y),size(W_in,2));
            W_out = back_propagation@GetOutput(obj,W_in).*obj.Mask;
        end
        function count = count_outputs(obj) 
            count = length(obj.Mesh.X)*length(obj.Mesh.Y);
        end
    end
end