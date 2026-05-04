classdef (Abstract) FreePropagator < Prop & handle
    properties
        distance;
        wavelength;
    end
    methods
        function gradient = get_gradient(obj)
            gradient = [];
        end
        function step(obj, gradient, speed)
        end
    end
end