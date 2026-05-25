classdef PhaseDOE < DOE
    properties (Access = protected, Constant)
        ssau = [linspace_l(40,  32, 40), linspace_l( 32,  255, 40), linspace_l(255, 201, 40), linspace_l(201, 40, 40);...
                linspace_l(40, 146, 40), linspace_l(146,  255, 40), linspace_l(255,  88, 40), linspace_l( 88, 40, 40);...
                linspace_l(40, 201, 40), linspace_l(201,  255, 40), linspace_l(255,  32, 40), linspace_l( 32, 40, 40)]'/255;
    end
    properties
        phi;
        mask;
        optimizer;
    end

    methods
        function obj = PhaseDOE(Mesh, prev, optimizer_fabric)
            obj = obj@DOE(Mesh, prev);
            if nargin < 3
                obj.optimizer = [];
                obj.mask = 0;
            else
                obj.optimizer = optimizer_fabric.generate(Mesh);
                obj.mask = 1;
            end
            obj.phi = GPUTest(zeros(size(Mesh)));
        end

        function obj = set_phi(obj, Phi)
            obj.phi = Phi;
        end

        function gradient = get_gradient(~, error)
            gradient = -imag(error);
        end

        function is = is_trainable(obj)
            is = sum(obj.mask, "all") > 0;
        end

        function imag = imagesc(obj)
            im = imagesc(obj.mesh.X, obj.mesh.Y, angle(get_transmission_function(obj)), [-pi pi]);
            colormap(obj.ssau); colorbar;
            axis square;
            if nargout > 0
                imag = im;
            end
        end

        function Field = get_transmission_function(obj)
            Field = exp(1i*obj.phi);
        end

        function make_gradient_step(obj, speed)
            if obj.is_trainable()
                obj.phi = obj.phi - speed * obj.optimizer.optimize(obj.Gradient);
            end
        end
    end
end