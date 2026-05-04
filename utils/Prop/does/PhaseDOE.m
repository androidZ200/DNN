classdef PhaseDOE < DOE
    properties (Access = protected, Constant)
        ssau = [linspace_l(40,  32, 40), linspace_l( 32,  255, 40), linspace_l(255, 201, 40), linspace_l(201, 40, 40);...
                linspace_l(40, 146, 40), linspace_l(146,  255, 40), linspace_l(255,  88, 40), linspace_l( 88, 40, 40);...
                linspace_l(40, 201, 40), linspace_l(201,  255, 40), linspace_l(255,  32, 40), linspace_l( 32, 40, 40)]'/255;
    end
    properties
        phi;
    end

    methods
        function obj = PhaseDOE(Mesh, optimizer_fabric)
            if nargin < 2
                optimizer_fabric = [];
            end
            obj = obj@DOE(Mesh, optimizer_fabric);
            obj.phi = GPUTest(zeros(size(Mesh)));
        end

        function obj = set_phi(obj, Phi)
            obj.phi = Phi;
        end
        function gradient = get_gradient(obj)
            gradient = -imag(obj.get_error());
        end
        function obj = circshift(obj,N)
            obj.Tensor = circshift(obj.phi, N);
            obj.Mask = circshift(obj.Train_Mask, N);
            if ~isempty(obj.optimizer)
                obj.optimizer = circshift(obj.optimizer, N);
            end
        end
        function obj = imagesc(obj)
            imagesc(obj.Mesh.X, obj.Mesh.Y, angle(get_field(obj)), [-pi pi]);
            
            colormap(obj.ssau); colorbar;
            axis square;
        end
        function Field = get_field(obj)
            Field = exp(1i*obj.phi);
        end
        function step(obj, gradient, speed)
            gradient = sum(gradient,setdiff(find(size(gradient)),[1 2]));
            gradient = obj.optimizer.optimize(gradient);
            obj.phi = obj.phi + speed*gradient.*obj.Train_Mask;
        end
    end
end