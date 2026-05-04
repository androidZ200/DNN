classdef (Abstract) OptimizerFabric
    methods (Abstract)
        optimizer = generate(Mesh);
    end
end