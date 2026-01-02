classdef Amplitude_DOE < DOE
    properties
        theta;
        mask = 1;
    end

    methods
        function obj = Amplitude_DOE(N, is_gpu, mask, ampl)
            if nargin > 3
                obj.theta = -log(1./min(max(ampl, 1e-8), 1 - 1e-8) - 1);
                obj.mask = mask;
            else
                if is_gpu
                    obj.theta = zeros(N, 'single', 'gpuArray');
                else
                    obj.theta = zeros(N, 'single');
                end
                if nargin > 2
                    obj.mask = mask;
                end
            end
        end

        function gradient = get_gradient(obj,error)
            sig = obj.sigmoid(obj.theta);
            gradient = real(error).*sig.*(1 - sig);
        end
        function gradient_step(obj,gradient)
            obj.theta = obj.theta + gradient.*obj.mask;
        end
        function obj = circshift(obj,N)
            obj.theta = circshift(obj.theta, N);
            obj.mask = circshift(obj.mask, N);
        end
        function Field = get_field(obj)
            Field = obj.sigmoid(obj.theta);
        end
    end

    methods (Access = private, Static)
        function y = sigmoid(x)
            y = 1./(1 + exp(-x));
        end
    end
end