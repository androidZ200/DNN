classdef AmplitudeDOE < DOE
    properties
        theta;
    end

    methods
        function obj = AmplitudeDOE(Mesh, optimizer_fabric)
            if nargin < 2
                optimizer_fabric = [];
            end
            obj = obj@DOE(Mesh, optimizer_fabric);
            obj.theta = GPUTest(zeros(size(Mesh)) - log(1/0.99 - 1));
        end

        function obj = set_amp(obj, Amp)
            Amp(Amp >= 1) = 1 - eps;
            Amp(Amp <= 0) = eps;
            obj.theta = -log(1./Amp - 1);
        end
        function gradient = get_gradient(obj)
            sig = obj.sigmoid(obj.theta);
            gradient = real(obj.get_error()).*sig.*(1 - sig);
        end
        function obj = circshift(obj,N)
            obj.theta = circshift(obj.theta, N);
            obj.Train_Mask = circshift(obj.Train_Mask, N);
            if ~isempty(obj.optimizer)
                obj.optimizer = circshift(obj.optimizer, N);
            end
        end
        function obj = imagesc(obj)
            imagesc(obj.Mesh.X, obj.Mesh.Y, get_field(obj), [0 1]);
            colormap(gray); colorbar;
            axis square;
        end
        function Field = get_field(obj)
            Field = obj.sigmoid(obj.theta);
        end
        function step(obj, gradient, speed)
            if obj.is_trainable()
                obj.theta = obj.theta + obj.preparing_gradient(gradient,speed);
            end
        end
    end

    methods (Access = private, Static)
        function y = sigmoid(x)
            y = 1./(1 + exp(-x));
        end
    end
end