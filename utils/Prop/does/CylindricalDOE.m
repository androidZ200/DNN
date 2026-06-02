classdef CylindricalDOE < DOE
    properties (SetAccess=private)
        data;
        mask;
        optimizer;
    end

    methods
        function obj = CylindricalDOE(prev, Mesh, type, dim, optimizer_fabric)
            obj = obj@DOE(prev, Mesh, type);
            switch dim
                case "X"
                    obj.data = GPUTest(zeros(size(Mesh.X)));
                case "Y"
                    obj.data = GPUTest(zeros(size(Mesh.Y)));
                otherwise
                    error("dimension not exist");
            end
            if nargin < 5
                obj.optimizer = [];
                obj.mask = 0;
            else
                obj.optimizer = optimizer_fabric.generate(obj.data);
                obj.mask = 1;
            end
        end

        function obj = set_data(obj, data)
            obj.data = data;
        end

        function gradient = get_gradient(obj, error)
            gradient = obj.type.get_gradient(error, obj.data);
            gradient = sum(gradient, find(size(obj.data)==1));
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
            im = obj.type.imagesc(obj.mesh.X, obj.mesh.Y, repmat(obj.data, 1+(size(obj.data)==1).*(size(obj.mesh)-1)));
            colorbar;
            axis square;
            if nargout > 0
                imag = im;
            end
        end
    end
end

