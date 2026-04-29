classdef PhaseDOE < DOE
    properties (Access = protected, Constant)
        ssau = [linspace_l(40,  32, 40), linspace_l( 32,  255, 40), linspace_l(255, 201, 40), linspace_l(201, 40, 40);...
                linspace_l(40, 146, 40), linspace_l(146,  255, 40), linspace_l(255,  88, 40), linspace_l( 88, 40, 40);...
                linspace_l(40, 201, 40), linspace_l(201,  255, 40), linspace_l(255,  32, 40), linspace_l( 32, 40, 40)]'/255;
    end

    methods
        function obj = PhaseDOE(pixel, N, is_gpu, optimizer_fabric)
            if nargin <= 3
                optimizer_fabric = SGDFabric();
            end
            obj = obj@DOE(pixel, N, is_gpu, optimizer_fabric);
        end

        function obj = set_phi(obj, Phi)
            obj.Tensor = Phi;
        end
        function gradient = get_gradient(obj)
            gradient = -imag(obj.get_error());
        end
        function obj = circshift(obj,N)
            obj.Tensor = circshift(obj.Tensor, N);
            obj.Mask = circshift(obj.Mask, N);
        end
        function obj = imagesc(obj)
            imagesc(obj.X, obj.Y, angle(get_field(obj)), [-pi pi]);
            
            colormap(obj.ssau); colorbar;
            axis square;
        end
        function Field = get_field(obj)
            Field = exp(1i*obj.Tensor);
        end
    end
end