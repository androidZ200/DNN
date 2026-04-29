classdef AmplitudeDOE < DOE
    methods
        function obj = AmplitudeDOE(pixel, N, is_gpu, optimizer_fabric)
            if nargin <= 3
                optimizer_fabric = SGDFabric();
            end
            obj = obj@DOE(pixel, N, is_gpu, optimizer_fabric);
        end

        function obj = set_amp(obj, Amp)
            Amp(Amp >= 1) = 1 - eps;
            Amp(Amp <= 0) = eps;
            obj.Tensor = -log(1./Amp - 1);
        end
        function gradient = get_gradient(obj)
            sig = obj.sigmoid(obj.Tensor);
            gradient = real(obj.get_error()).*sig.*(1 - sig);
        end
        function obj = circshift(obj,N)
            obj.theta = circshift(obj.theta, N);
            obj.mask = circshift(obj.mask, N);
        end
        function obj = imagesc(obj)
            imagesc(obj.X, obj.Y, get_field(obj), [0 1]);
            colormap(gray); colorbar;
            axis square;
        end
        function Field = get_field(obj)
            Field = obj.sigmoid(obj.Tensor);
        end
    end

    methods (Access = private, Static)
        function y = sigmoid(x)
            y = 1./(1 + exp(-x));
        end
    end
end