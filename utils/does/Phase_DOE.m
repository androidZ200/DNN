classdef Phase_DOE < DOE
    properties
        phi;
        mask = 1;
    end
    properties (Access = protected, Constant)
        ssau = [linspace_l(40,  32, 40), linspace_l( 32,  255, 40), linspace_l(255, 201, 40), linspace_l(201, 40, 40);...
                linspace_l(40, 146, 40), linspace_l(146,  255, 40), linspace_l(255,  88, 40), linspace_l( 88, 40, 40);...
                linspace_l(40, 201, 40), linspace_l(201,  255, 40), linspace_l(255,  32, 40), linspace_l( 32, 40, 40)]'/255;
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
        function obj = imagesc(obj)
            imagesc(angle(get_field(obj)), [-pi pi]);
            
            colormap(obj.ssau); colorbar;
            axis square;
        end
        function Field = get_field(obj)
            Field = exp(1i*obj.phi);
        end
    end
end