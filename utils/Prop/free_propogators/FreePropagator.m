classdef (Abstract) FreePropagator < Prop & handle
    properties
        f;
        lambda;
    end
    methods (Abstract)
        init(Before,After);
    end
end