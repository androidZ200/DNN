classdef ASMPropagator < FreePropagator
    properties
        U;
        mesh = [];
    end

    methods
        function obj = ASMPropagator(f,lambda)
            obj.f = f;
            obj.lambda = lambda;
        end

        function init(obj,Before,After)
            if isa(Before, 'Prop')
                mesh_in = Before.output_mesh();
            elseif isa(Before, 'Mesh')
                mesh_in = Before;
            else
                error('before is not propagator or mesh'); 
            end
            if isa(After, 'Prop')
                mesh_out = After.input_mesh();
            elseif isa(Before, 'Mesh')
                mesh_out = After;
            else
                error('after is not propagator or mesh'); 
            end

            ky = 0; kx = 0; Ny = 0; Nx = 0;
            if ~isempty(mesh_in.Y) && ~isempty(mesh_out.Y)
                if ~isequal(mesh_in.Y, mesh_out.Y)
                    error('grid Y is not equal');
                end
                Ny = length(mesh_in.Y); pixely = (mesh_in.Y(end) - mesh_in.Y(1))/(Ny-1);
                ky = linspace_l(-pi/pixely, pi/pixely, Ny).';
            end
            if ~isempty(mesh_in.X) && ~isempty(mesh_out.X)
                if ~isequal(mesh_in.X, mesh_out.X)
                    error('grid X is not equal');
                end
                Nx = length(mesh_in.X); pixelx = (mesh_in.X(end) - mesh_in.X(1))/(Nx-1);
                kx = linspace_l(-pi/pixelx, pi/pixelx, Nx);
            end
            obj.mesh = mesh_in;

            T = circshift(kx.^2 + ky.^2, [Nx/2 Ny/2]);
            obj.U = exp(1i*obj.f.*single(sqrt((2*pi/obj.lambda).^2 - T)));
        end

        function W = propagation(obj, W)
            W = ifft2(fft2(W).*obj.U);
        end
        function W = back_propagation(obj, W)
            W = obj.propagation(W);
        end
        function mesh = input_mesh(obj)
            if ~empty(obj.mesh)
                mesh = obj.mesh;
            else
                error('mesh does not initialize');
            end
        end
        function mesh = output_mesh(obj)
            mesh = obj.input_mesh();
        end
    end
end