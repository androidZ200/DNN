classdef FullDOE < DOE
    properties (SetAccess=private)
        data;
        mask;
        optimizer;
    end

    methods
        function obj = FullDOE(prev, Mesh, type, optimizer_fabric)
            obj = obj@DOE(prev, Mesh, type);
            if nargin < 4
                obj.optimizer = [];
                obj.mask = 0;
            else
                obj.optimizer = optimizer_fabric.generate(Mesh);
                obj.mask = 1;
            end
            obj.data = GPUTest(zeros(size(Mesh)));
        end

        function obj = set_data(obj, data)
            if ~isequal(size(data), size(obj.data))
                error("the sizes of the arrays do not match");
            end
            obj.data = GPUTest(data);
        end

        function gradient = get_gradient(obj, error)
            gradient = obj.type.get_gradient(error, obj.data);
        end

        function is = is_trainable(obj)
            is = sum(obj.mask, "all") > 0;
        end

        function field = get_transmission_function(obj)
            field = obj.type.get_transmission_function(obj.data);
        end

        function make_gradient_step(obj, gradient, speed)
            if obj.is_trainable()
                obj.data = obj.data - speed * obj.optimizer.optimize(gradient);
            end
        end

        function imag = imagesc(obj)
            im = obj.type.imagesc(obj.mesh.X, obj.mesh.Y, obj.data);
            colorbar;
            axis square;
            if nargout > 0
                imag = im;
            end
        end
    end
end