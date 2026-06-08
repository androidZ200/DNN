classdef ClassificationTarget < GetTarget
    properties (SetAccess = private)
        matrix
    end
    
    methods
        function obj = ClassificationTarget(count_output, count_class)
            obj.matrix = GPUTest(eye(count_output, count_class));
        end
        
        function target = get_target(obj, index)
            target = obj.matrix(:,index);
        end
    end
end

