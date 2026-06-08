classdef GenerationTarget < GetTarget
    properties (SetAccess = private)
        images
    end
    
    methods
        function obj = GenerationTarget(images)
            obj.images = GPUTest(reshape(images, size(images,1)*size(images,2), size(images,3)));
        end
        
        function target = get_target(obj, index)
            if (size(obj.images,3)==1)
                target = obj.images;
            else
                target = obj.images(:,index);
            end
        end
    end
end

