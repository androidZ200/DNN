classdef Phase_DOE < DOE
    properties
        phi;
        mask = 1;
    end

    methods
        function obj = Phase_DOE(N, is_gpu, mask, phi)
            if nargin > 3
                obj.phi = phi;
                obj.mask = mask;
            else
                if is_gpu
                    obj.phi = zeros(N, 'single', 'gpuArray');
                else
                    obj.phi = zeros(N, 'single');
                end
                if nargin > 2
                    obj.mask = mask;
                end
            end
        end

        function gradient = get_gradient(obj,error)
            gradient = -imag(error);
        end
        function gradient_step(obj,gradient)
            obj.phi = obj.phi + gradient.*obj.mask;
        end
        function obj = circshift(obj,N)
            obj.phi = circshift(obj.phi, N);
            obj.mask = circshift(obj.mask, N);
        end
        function Field = get_field(obj)
            Field = exp(1i*obj.phi);
        end
    end
end