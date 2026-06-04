classdef GetFullIntensity < GetOutput
    properties (SetAccess=protected)
        Mask;
    end

    methods
        function obj = GetFullIntensity(Mesh, prev, Mask)
            obj = obj@GetOutput(Mesh, prev);
            if(nargin > 2)
                obj.Mask = GPUTest(Mask);
            else
                obj.Mask = 1;
            end
        end

        function score = get_output(obj, input)
            input = get_output@GetOutput(obj,input).*obj.Mask;
            score = reshape(input,[],size(input,3));
        end
        function I = intensity(obj, input)
            out = get_output(obj,input);
            I = reshape(out,length(obj.Mesh.X),length(obj.Mesh.Y),size(out,2));
        end
        function set_error_field(obj, error)
            error = reshape(error,length(obj.Mesh.X),length(obj.Mesh.Y),size(error,2));
            set_error_field@GetOutput(obj, error.*obj.Mask);
        end
        function count = count_outputs(obj) 
            count = length(obj.Mesh.X)*length(obj.Mesh.Y);
        end
    end
end