classdef AmplitudeDOE < DOE
    properties
        theta;
        mask;
        optimizer;
    end

    methods
        function obj = AmplitudeDOE(Mesh, prev, optimizer_fabric)
            obj = obj@DOE(Mesh, prev);
            if nargin < 3
                obj.optimizer = [];
                obj.mask = 0;
            else
                obj.optimizer = optimizer_fabric.generate(Mesh);
                obj.mask = 1;
            end
            obj.theta = GPUTest(zeros(size(Mesh)) - log(1/0.99 - 1));
        end

        function obj = set_amp(obj, Amp)
            Amp(Amp >= 1) = 1 - eps;
            Amp(Amp <= 0) = eps;
            obj.theta = -log(1./Amp - 1);
        end

        function gradient = get_gradient(obj, error)
            sig = obj.sigmoid(obj.theta);
            gradient = real(error).*sig.*(1 - sig);
        end

        function is = is_trainable(obj)
            is = sum(obj.mask, "all") > 0;
        end

        function imag = imagesc(obj)
            im = imagesc(obj.mesh.X, obj.mesh.Y, get_transmission_function(obj), [0 1]);
            colormap(gray); colorbar;
            axis square;
            if nargout > 0
                imag = im;
            end
        end

        function Field = get_transmission_function(obj)
            Field = obj.sigmoid(obj.theta);
        end

        function make_gradient_step(obj, speed)
            if obj.is_trainable()
                obj.theta = obj.theta - speed * obj.optimizer.optimize(obj.Gradient);
            end
        end
    end

    methods (Access = private, Static)
        function y = sigmoid(x)
            y = 1./(1 + exp(-x));
        end
    end
end